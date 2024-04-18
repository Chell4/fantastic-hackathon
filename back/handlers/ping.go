package handlers

import (
	"net/http"

	"github.com/gorilla/mux"
)

func (s *HandlersServer) HandlePing(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	pong, _ := vars["pong"]
	if pong == "" {
		pong = "pong"
	}

	w.Write([]byte(pong))
}
