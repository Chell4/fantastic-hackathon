package handlers

import (
	"net/http"

	"github.com/gorilla/mux"
)

func (s *HandlersServer) HandlePing(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		s.HandlePingGet(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandlePingGet(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	pong := vars["pong"]
	if pong == "" {
		pong = "pong"
	}

	w.Write([]byte(pong))
}
