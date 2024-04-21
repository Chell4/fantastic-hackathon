package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
)

type ProfileIDResponse struct {
	FirstName   string `json:"first_name"`
	SecondName  string `json:"second_name"`
	LastName    string `json:"last_name"`
	Phone       string `json:"phone"`
	Description string `json:"description"`
}

func (s *HandlersServer) HandleProfileID(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "GET":

	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleProfileIDGet(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	id, has := vars["id"]
	if !has {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "id",
			"explain": ErrExplainIDNotGiven,
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
			"type":    "profile",
			"reason":  "id",
			"explain": ErrExplainIDnotExist,
		})
		return
	}

	var user User
	err = s.DB.Table("users").Where("id = ?", id).Take(&user).Error
	if CheckServerError(w, err) {
		return
	}

	secondName := ""
	if user.SecondName != nil {
		secondName = *user.SecondName
	}
	description := ""
	if user.Description != nil {
		description = *user.Description
	}

	respJSON, err := json.Marshal(&ProfileIDResponse{
		FirstName:   user.FirstName,
		SecondName:  secondName,
		LastName:    user.LastName,
		Phone:       user.Phone,
		Description: description,
	})
	if CheckServerError(w, err) {
		return
	}

	_, err = w.Write(respJSON)
	if CheckServerError(w, err) {
		return
	}
}
