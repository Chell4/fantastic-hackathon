package main

import (
	"fmt"
	"net/http"

	"github.com/gorilla/mux"
)

type Server struct {
	address string
}

func NewServer(address string) Server {
	return Server{
		address: address,
	}
}

type Endpoints = map[string]func(http.ResponseWriter, *http.Request)

func (s *Server) endpoints() Endpoints {
	return Endpoints{
		"/ping":          s.HandlePing,
		"/auth/sign-in":  s.HandlePing,
		"/auth/register": s.HandlePing,
		"/{username}":    s.HandleUser,
	}
}

func (s *Server) StartServer() error {
	mulx := mux.NewRouter()

	for endpoint, handler := range s.endpoints() {
		mulx.HandleFunc(endpoint, handler)
	}

	err := http.ListenAndServe(s.address, mulx)
	if err != nil {
		return err
	}

	return nil
}

func (s *Server) HandlePing(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("pong"))
}

func (s *Server) HandleUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	w.Write([]byte(fmt.Sprintf("%v is gay", vars["username"])))
}
