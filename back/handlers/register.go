package handlers

import (
	"net/http"
)

const (
	ErrStatusCannotReadBody = "Request body is not readable"
	ErrStatusInvalidJSON    = "Invlalid json schema"
	ErrStatusDatabaseErr    = "Error while interacting with database"
	ErrStatusUserExists     = "User with this login already exists"
)

const BcryptCost = 10

type RegisterRequest struct {
	Login     string `json:"login"`
	Passwords string `json:"password"`
	Email     string `json:"email"`
}

type RegisterResponse struct {
}

func (s *HandlersServer) HandleRegister(w http.ResponseWriter, r *http.Request) {
}
