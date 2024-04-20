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
	WriteHeadersForFront(w)

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

	var cntUsers int64
	err = s.DB.Table("users").Where("phone = ?", req.Phone).Count(&cntUsers).Error
	if CheckServerError(w, err) {
		return
	}

	if cntUsers != 0 {
		ErrorMap(w, http.StatusConflict, map[string]interface{}{
			"type":    "register",
			"reason":  "phone_exist",
			"explain": ErrExplainPhoneExists,
		})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password)[:min(len(req.Password), 72)], BcryptCost)
	if CheckServerError(w, err) {
		return
	}

	err = s.DB.Table("users").Create(&User{
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
