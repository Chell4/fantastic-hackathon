package main

import (
	"net/http"
	"time"

	. "back/handlers"

	"github.com/gorilla/mux"
	"github.com/patrickmn/go-cache"
	"gorm.io/gorm"
)

type Server struct{ HandlersServer }

func NewServer(address string, db *gorm.DB) Server {
	return Server{HandlersServer: HandlersServer{
		Address:  address,
		DB:       db,
		JWTcache: cache.New(24*time.Hour, 10*time.Minute),
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

		`/profile`: s.HandleProfile,

		`/media/{img_name}`: s.HandleMedia,
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
