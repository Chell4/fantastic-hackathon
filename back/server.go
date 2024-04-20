package main

import (
	"net/http"

	. "back/handlers"

	"github.com/gorilla/mux"
	"github.com/robfig/cron/v3"
	"gorm.io/gorm"
)

type Server struct{ HandlersServer }

func NewServer(address string, db *gorm.DB) Server {
	return Server{HandlersServer: HandlersServer{
		Address:     address,
		DB:          db,
		Cron:        cron.New(),
		CronProcess: nil,
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

		`/media/{path}`: s.HandleMedia,
		`/schedule`:     s.HandleSchedule,
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
