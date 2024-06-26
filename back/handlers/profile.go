package handlers

import (
	"encoding/json"
	"io"
	"log"
	"net/http"

	"golang.org/x/crypto/bcrypt"
)

type ProfileGetResponse struct {
	ID         string `json:"id"`
	FirstName  string `json:"first_name"`
	SecondName string `json:"second_name"`
	LastName   string `json:"last_name"`
	Phone      string `json:"phone"`
	Descripton string `json:"description"`
	IsAdmin    bool   `json:"is_admin"`
	IsReady    bool   `json:"is_ready"`
}

type ProfilePostRequest struct {
	FirstName   string `json:"first_name"`
	SecondName  string `json:"second_name"`
	LastName    string `json:"last_name"`
	Phone       string `json:"phone"`
	OldPassword string `json:"old_password"`
	Password    string `json:"password"`
	Description string `json:"description"`
}

func (s *HandlersServer) HandleProfile(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "GET":
		s.HandleProfileGet(w, r)
	case "POST":
		s.HandleProfilePost(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleProfileGet(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	log.Println(user)

	secondName := ""
	if user.SecondName != nil {
		secondName = *user.SecondName
	}

	description := ""
	if user.Description != nil {
		description = *user.Description
	}

	ErrorMap(w, http.StatusOK, ProfileGetResponse{
		ID:         user.ID,
		FirstName:  user.FirstName,
		SecondName: secondName,
		LastName:   user.LastName,
		Phone:      user.Phone,
		Descripton: description,
		IsAdmin:    user.IsAdmin,
		IsReady:    user.IsReady,
	})
}

func (s *HandlersServer) HandleProfilePost(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	reqJSON, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
		return
	}

	var req ProfilePostRequest
	err = json.Unmarshal(reqJSON, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
	}

	if req.FirstName != "" {
		user.FirstName = req.FirstName
	}
	if req.SecondName != "" {
		user.SecondName = &req.SecondName
	}
	if req.LastName != "" {
		user.LastName = req.LastName
	}
	if req.Phone != "" {
		user.Phone = req.Phone
	}
	if req.Password != "" {
		err = bcrypt.CompareHashAndPassword(
			user.PasswordHash,
			[]byte(req.OldPassword)[:min(len(req.OldPassword), 72)],
		)
		if err != nil {
			ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
				"type":    "edit",
				"reason":  "old_password",
				"explain": ErrExplainWrongOldPassword,
			})
			return
		}

		user.PasswordHash, err = bcrypt.GenerateFromPassword(
			[]byte(req.Password)[:min(len(req.Password), 72)],
			BcryptCost,
		)
		if CheckServerError(w, err) {
			return
		}
	}
	if req.Description != "" {
		user.Description = &req.Description
	}

	err = s.DB.Table("users").Save(user).Error
	if CheckServerError(w, err) {
		return
	}

	w.WriteHeader(http.StatusOK)
}
