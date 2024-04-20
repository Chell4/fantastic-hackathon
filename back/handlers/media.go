package handlers

import (
	"encoding/json"
	"io"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

type PictureRequest struct {
	Picture []byte `json:"picture"`
}

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

	req, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "media",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
		return
	}
	var pic PictureRequest
	err = json.Unmarshal(req, &pic)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "media",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
		return
	}
	err = os.WriteFile("/media/"+path, pic.Picture, 0666)
	if CheckServerError(w, err) {
		return
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
