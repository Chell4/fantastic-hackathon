package handlers

import (
	"encoding/json"
	"io"
	"net/http"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type RegisterRequest struct {
	Phone     string `json:"phone"`
	Password  string `json:"password"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

func (s *HandlersServer) HandleRegister(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "POST":
		s.HandleRegisterPost(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleRegisterPost(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
		return
	}

	var req RegisterRequest
	err = json.Unmarshal(body, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
		return
	}

	switch {
	case req.Phone == "":
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "register",
			"reason":  "no_phone",
			"explain": ErrExplainNoPhone,
		})
		return

	case req.Password == "":
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "register",
			"reason":  "no_password",
			"explain": ErrExplainNoPassword,
		})
		return
	case req.FirstName == "":
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "register",
			"reason":  "no_first_name",
			"explain": ErrExplainNoFirstName,
		})
		return
	case req.LastName == "":
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "register",
			"reason":  "no_last_name",
			"explain": ErrExplainNoLastName,
		})
		return
	default:
	}

	var cnt int64
	err = s.DB.Table("users").Where("phone = ?", req.Phone).Count(&cnt).Error
	if CheckServerError(w, err) {
		return
	}

	if cnt != 0 {
		ErrorMap(w, http.StatusConflict, map[string]interface{}{
			"type":    "register",
			"reason":  "phone_exist",
			"explain": ErrExplainPhoneExists,
		})
		return
	}

	err = s.DB.Table("reg_reqs").Where("phone = ?", req.Phone).Count(&cnt).Error
	if CheckServerError(w, err) {
		return
	}

	if cnt != 0 {
		ErrorMap(w, http.StatusConflict, map[string]interface{}{
			"type":    "register",
			"reason":  "phone_exist",
			"explain": ErrExplainRegRequestExist,
		})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password)[:min(len(req.Password), 72)], BcryptCost)
	if CheckServerError(w, err) {
		return
	}

	err = s.DB.Table("reg_reqs").Create(&RegReq{
		ID:           uuid.NewString(),
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		PasswordHash: hash,
		Phone:        req.Phone,
	}).Error
	if CheckServerError(w, err) {
		return
	}

	w.WriteHeader(http.StatusCreated)
}
