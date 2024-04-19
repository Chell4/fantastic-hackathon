package handlers

import (
	"encoding/json"
	"io"
	"net/http"

	"golang.org/x/crypto/bcrypt"
)

type LoginRequest struct {
	Phone    string `json:"phone"`
	Password string `json:"password"`
}

func (s *HandlersServer) HandleLogin(w http.ResponseWriter, r *http.Request) {
	reqJSON, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, ErrStatusCannotReadBody, http.StatusBadRequest)
		return
	}

	var logReq LoginRequest
	err = json.Unmarshal(reqJSON, &logReq)
	if err != nil {
		http.Error(w, ErrStatusInvalidJSON, http.StatusBadRequest)
		return
	}

	var cntUsers int64
	err = s.DB.Table("users").Where("phone_number = ?", logReq.Phone).Count(&cntUsers).Error
	if CheckServerError(w, err) {
		return
	}

	if cntUsers == 0 {
		http.Error(w, ErrStatusLoginUserNotExists, http.StatusUnauthorized)
		return
	}

	var user User
	err = s.DB.Table("users").Where("phone_numger = ?", logReq.Phone).First(&user).Error
	if CheckServerError(w, err) {
		return
	}

	err = bcrypt.CompareHashAndPassword(user.PasswordHash, []byte(logReq.Password))
	if err != nil {
		http.Error(w, ErrStatusWrongPassword, http.StatusUnauthorized)
		return
	}

}
