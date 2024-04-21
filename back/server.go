package main

import (
	"net/http"
	"os"

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

		`/auth/ping`:            s.HandleAuthPing,
		`/auth/ping/{pong:\w*}`: s.HandleAuthPing,
		`/auth/login`:           s.HandleLogin,
		`/auth/register`:        s.HandleRegister,

		`/profile`:         s.HandleProfile,
		`/profile/{id}`:    s.HandleProfileID,
		`/profile/matches`: s.HandlePing,
		`/profile/ready`:   s.HandleReady,

		`/admin/add`:      s.HandleAddAdmin,
		`/admin/userlist`: s.HandleUserList,
		`/admin/requests`: s.HandleRegRequests,
		`/admin/coffee`:   s.HandleCoffee,
		`/admin/matches`:  s.HandlePing,

		`/media/{id}`: s.HandleMedia,
		`/media`:      s.HandleMyMedia,
	}
}

func (s *Server) StartServer() error {
	mulx := mux.NewRouter()

	for endpoint, handler := range s.endpoints() {
		mulx.HandleFunc(endpoint, handler)
	}

	cert := os.Getenv("CERTIFICATE")
	key := os.Getenv("SSL_KEY")

	var err error
	if cert == "" || key == "" {
		err = http.ListenAndServe(s.Address, mulx)
	} else {
		err = http.ListenAndServeTLS(s.Address, cert, key, mulx)
	}
	if err != nil {
		return err
	}

	return nil
}
