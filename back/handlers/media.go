package handlers

import (
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func (s *HandlersServer) HandleMedia(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	path, has := vars["path"]
	if !has {
		http.Error(w, http.StatusText(http.StatusBadRequest), http.StatusBadRequest)
		return
	}

	pic, err := os.ReadFile("../media/" + path)
	if err != nil {
		http.Error(w, ErrStatusInvalidMedia, http.StatusBadRequest)
		return
	}

	w.Write(pic)
}
