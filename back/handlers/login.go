package handlers

import (
	"crypto/sha1"
	"encoding/json"
	"io"
	"log"
	"net/http"
)

type LoginRequest struct {
	googleID string `json:"google_id"`
	photoURL string `json:"photo_url"`
}

func (s *HandlersServer) HandleLogin(w http.ResponseWriter, r *http.Request) {
	bodyJSON, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, ErrStatusCannotReadBody, http.StatusBadRequest)
		log.Println(err)
		return
	}

	var logReq LoginRequest
	err = json.Unmarshal(bodyJSON, &logReq)
	if err != nil {
		http.Error(w, ErrStatusInvalidJSON, http.StatusBadRequest)
		log.Println(err)
		return
	}

	var userCnt int64
	err = s.DB.Table("users").Where("id = $1", logReq.googleID).Count(&userCnt).Error
	if err != nil {
		http.Error(w, ErrStatusDatabaseErr, http.StatusInternalServerError)
		log.Println(err)
		return
	}

	if userCnt != 0 {
		http.Error(w, ErrStatusUserExists, http.StatusConflict)
		log.Println(err)
		return
	}

	photoResp, err := http.Get(logReq.photoURL)
	if err != nil {
		http.Error(w, ErrStatusInvalidPhotoURL, http.StatusBadRequest)
		log.Println(err)
		return
	}

	photoData, err := io.ReadAll(photoResp.Body)
	if CheckServerError(w, err) {
		return
	}

	hash := sha1.New()
	_, err = hash.Write(photoData)
	if CheckServerError(w, err) {
		return
	}

	hashData := hash.Sum(nil)

	//err = s.DB.Table("users").Create(&User{})
}
