package handlers

import "net/http"

type LoginRequest struct {
	googleID    string `json:"google_id"`
	googleToken string `json:"google_token"`
}

type LoginResponse struct {
	googleID string `json:"google_id"`
}

func (s *HandlersServer) HandleLogin(w http.ResponseWriter, r *http.Request) {

}
