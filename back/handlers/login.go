package handlers

import (
	"io"
	"net/http"
)

type LoginRequest struct {
	Phone    string `json:"phone"`
	Password string `json:"password"`
}

func (s *HandlersServer) HandleLogin(w http.ResponseWriter, r *http.Request) {
	reqJSON, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, ErrStatusCannotReadBody, http.StatusBadRequest)
	}

	logReq
}
