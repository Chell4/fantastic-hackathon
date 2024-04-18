package handlers

import (
	"fmt"
	"net/http"

	"github.com/gorilla/mux"
)

func (s *HandlersServer) HandleUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	w.Write([]byte(fmt.Sprintf("%v is gay", vars["username"])))
}
