package main

import (
	"net/http"

	. "back/handlers"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

type Server struct{ HandlersServer }

func NewServer(address string, db *gorm.DB) Server {
	return Server{HandlersServer: HandlersServer{
		Address: address,
		DB:      db,
	}}
}

type Endpoints = map[string]func(http.ResponseWriter, *http.Request)

func (s *Server) endpoints() Endpoints {
	return Endpoints{
		`/ping`:            s.HandlePing,
		`/ping/{pong:\w*}`: s.HandlePing,

		`/auth/login`:    s.HandleLogin,
		`/auth/register`: s.HandleRegister,
		`/auth/logout`:   s.HandleLogout,

		`/{username:[^/]{5,}}`:              s.HandleUser,
		`/{username:[^/]{5,}}/{action:\w*}`: s.HandleUser,
	}
}

func (s *Server) StartServer() error {
	mulx := mux.NewRouter()

	for endpoint, handler := range s.endpoints() {
		mulx.HandleFunc(endpoint, handler)
	}

	err := http.ListenAndServe(s.Address, mulx)
	if err != nil {
		return err
	}

	return nil
}
