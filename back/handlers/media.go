package handlers

import (
	"net/http"
	"os"
	"path/filepath"

	"github.com/gorilla/mux"
)

func (s *HandlersServer) HandleMedia(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "GET":
		s.HandleMediaGet(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleMediaGet(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	id, has := vars["id"]
	if !has {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "id",
			"explain": ErrExplainMediaIDNotGiven,
		})
		return
	}

	var cnt int64
	err := s.DB.Table("users").Where("id = ?", id).Count(&cnt).Error
	if CheckServerError(w, err) {
		return
	}

	if cnt == 0 {
		ErrorMap(w, http.StatusNotFound, map[string]interface{}{
			"type":    "media",
			"reason":  "id",
			"explain": ErrExplainIDnotExist,
		})
		return
	}

	var path string
	err = s.DB.Table("users").Select("picture_path").Where("id = ?", id).Take(&path).Error
	if CheckServerError(w, err) {
		return
	}

	ex, err := os.Executable()
	if CheckServerError(w, err) {
		return
	}
	exPath := filepath.Dir(ex)

	pic, err := os.ReadFile(exPath + "/media/" + path)
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
