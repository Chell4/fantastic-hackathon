package handlers

import (
	"io"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func (s *HandlersServer) HandleMedia(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		s.HandleMediaGet(w, r)
	case "POST":
		s.HandleMediaPost(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleMediaGet(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	path, has := vars["path"]
	if !has {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "path",
			"explain": ErrExplainInvalidPhotoURL,
		})
		return
	}

	pic, err := os.ReadFile("media/" + path)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "media",
			"reason":  "path",
			"explain": ErrExplainInvalidMedia,
		})
		return
	}

	w.Write(pic)
}

func (s *HandlersServer) HandleMediaPost(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	path, has := vars["path"]
	if !has {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "path",
			"explain": ErrExplainInvalidPhotoURL,
		})
		return
	}

	reqPic, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
		return
	}
	err = os.WriteFile("/media/"+path, reqPic, 0644)
	if CheckServerError(w, err) {
		return
	}

	w.WriteHeader(http.StatusCreated)
}
