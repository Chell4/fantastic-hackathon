package handlers

import (
	"crypto/md5"
	"encoding/base64"
	"io"
	"net/http"
	"os"
	"path/filepath"
)

func (s *HandlersServer) HandleMyMedia(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "GET":
		s.HandleMyMediaGet(w, r)
	case "POST":
		s.HandleMyMediaPost(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleMyMediaGet(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	if user.PicturePath == nil {
		ErrorMap(w, http.StatusNotFound, map[string]interface{}{
			"type":    "media",
			"reason":  "path",
			"explain": ErrExplainInvalidMedia,
		})
		return
	}

	pic, err := os.ReadFile("media/" + *user.PicturePath)
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

func (s *HandlersServer) HandleMyMediaPost(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	picData, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
	}

	ex, err := os.Executable()
	if err != nil {
		panic(err)
	}
	exPath := filepath.Dir(ex)

	hash := md5.New()
	_, err = hash.Write(picData)
	if CheckServerError(w, err) {
		return
	}
	hashData := hash.Sum(nil)

	hashDataStr := base64.StdEncoding.EncodeToString(hashData)

	err = os.WriteFile(exPath+"media/"+hashDataStr, picData, 0644)
	if CheckServerError(w, err) {
		return
	}

	err = s.DB.Table("users").Where("id = ?", user.ID).Update("picture_path", hashDataStr).Error
	if CheckServerError(w, err) {
		return
	}
}
