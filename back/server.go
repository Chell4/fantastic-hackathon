package main

import (
	"net/http"

	. "back/handlers"

	"github.com/gorilla/mux"
)

type Server struct {
	HandlersServer
}

func NewServer(Address string) Server {
	return Server{HandlersServer: HandlersServer{
		Address: Address,
	}}
}

type Endpoints = map[string]func(http.ResponseWriter, *http.Request)

func (s *Server) endpoints() Endpoints {
	return Endpoints{
		`/ping`:                             s.HandlePing,
		`/ping/{pong:\w*}`:                  s.HandlePing,
		`/auth/sign-in`:                     s.HandlePing,
		`/auth/register`:                    s.HandlePing,
		`/auth/logout`:                      s.HandlePing,
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