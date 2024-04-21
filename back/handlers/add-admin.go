package handlers

import (
	"encoding/json"
	"io"
	"net/http"
)

type AddAdminPostRequest struct {
	ID string `json:"id"`
}

func (s *HandlersServer) HandleAddAdmin(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "POST":
		s.HandleAddAdminPost(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleAddAdminPost(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	if !user.IsAdmin {
		ErrorMap(w, http.StatusMethodNotAllowed, map[string]interface{}{
			"type":    "admin",
			"reason":  "not_admin",
			"explain": ErrExplainNotAdmin,
		})
		return
	}

	reqJSON, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
	}

	var req AddAdminPostRequest
	err = json.Unmarshal(reqJSON, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
	}

	var cnt int64
	err = s.DB.Table("users").Where("id = ?", req.ID).Count(&cnt).Error
	if CheckServerError(w, err) {
		return
	}

	if cnt == 0 {
		ErrorMap(w, http.StatusNotFound, map[string]interface{}{
			"type":    "id",
			"reason":  "not_exist",
			"explain": ErrExplainIDnotExist,
		})
		return
	}

	err = s.DB.Table("users").Where("id = ?", req.ID).Update("is_admin", true).Error
	if CheckServerError(w, err) {
		return
	}

	w.WriteHeader(http.StatusOK)
}
