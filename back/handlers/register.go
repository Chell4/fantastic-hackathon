package handlers

import (
	"encoding/json"
	"io"
	"net/http"

	"golang.org/x/crypto/bcrypt"
)

const (
	ErrStatusCannotReadBody = "Request body is not readable"
	ErrStatusInvalidJSON    = "Invlalid json schema"
)

const BcryptCost = 10

type RegisterRequest struct {
	Login     string `json:"login"`
	Passwords string `json:"password"`
	Email     string `json:"email"`
}

type RegisterResponse struct {
	UserID string `json:"user_id"`
}

func (s *HandlersServer) HandleRegister(w http.ResponseWriter, r *http.Request) {
	bodyJSON, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, ErrStatusCannotReadBody, http.StatusBadRequest)
		return
	}

	var registerReq RegisterRequest
	err = json.Unmarshal(bodyJSON, &registerReq)
	if err != nil {
		http.Error(w, ErrStatusInvalidJSON, http.StatusBadRequest)
		return
	}

	passHash, _ := bcrypt.GenerateFromPassword([]byte(registerReq.Passwords)[:72], BcryptCost)

}
