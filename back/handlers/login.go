package handlers

import (
	"encoding/json"
	"io"
	"net/http"
)

type LoginRequest struct {
	googleID    string `json:"google_id"`
	googleToken string `json:"google_token"`
}

type LoginResponse struct {
	googleID string `json:"google_id"`
}

func (s *HandlersServer) HandleLogin(w http.ResponseWriter, r *http.Request) {
	bodyJSON, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, ErrStatusCannotReadBody, http.StatusBadRequest)
		return
	}

	var logReq LoginRequest
	err = json.Unmarshal(bodyJSON, &logReq)
	if err != nil {
		http.Error(w, ErrStatusInvalidJSON, http.StatusBadRequest)
		return
	}

	var userCnt int64
	err = s.DB.Table("users").Where("id = $1", logReq.googleID).Count(&userCnt).Error
	if err != nil {
		http.Error(w, ErrStatusDatabaseErr, http.StatusInternalServerError)
		return
	}

	if userCnt == 0 {
		http.Error(w, ErrStatusRegisterUserNotExists, http.StatusNotFound)
		return
	}
}
