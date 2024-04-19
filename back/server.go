package main

import (
	"net/http"
	"time"

	. "back/handlers"

	"github.com/gorilla/mux"
	"github.com/patrickmn/go-cache"
	"github.com/robfig/cron/v3"
	"gorm.io/gorm"
)

type Server struct{ HandlersServer }

func NewServer(address string, db *gorm.DB) Server {
	return Server{HandlersServer: HandlersServer{
		Address:  address,
		DB:       db,
		JWTcache: cache.New(24*time.Hour, 10*time.Minute),
		Schedule: cron.New()
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

	s.Schedule.AddFunc("CRON_TZ=Europe/Moscow 0 0 * * 1", ...)
	s.Schedule.Start()
	return nil
}
