package handlers

import (
	"net/http"

	"github.com/gorilla/mux"
)

func (s *HandlersServer) HandleAuthPing(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		s.HandleAuthPingGet(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleAuthPingGet(w http.ResponseWriter, r *http.Request) {
	if _, valid := s.ValidateToken(w, r); !valid {
		return
	}

	vars := mux.Vars(r)

	pong := vars["pong"]
	if pong == "" {
		pong = "pong"
	}

	w.Write([]byte(pong))
}
