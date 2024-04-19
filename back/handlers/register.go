package handlers

import (
	"net/http"
)

type RegisterRequest struct {
	Login     string `json:"login"`
	Passwords string `json:"password"`
	Email     string `json:"email"`
}

type RegisterResponse struct {
}

func (s *HandlersServer) HandleRegister(w http.ResponseWriter, r *http.Request) {

}
