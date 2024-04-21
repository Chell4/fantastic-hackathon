package handlers

import (
	"encoding/json"
	"io"
	"net/http"
)

type RegRequestPostRequest struct {
	Offset int `json:"offset"`
	Size   int `json:"size"`
}

type RegRequestData struct {
	ID        string `json:"id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Phone     string `json:"phone"`
}

type RegRequestPostResponse struct {
	Requests []RegRequestData `json:"requests"`
}

type RegRequestPutRequest struct {
	ID     string `json:"id"`
	Accept bool   `json:"accept"`
}

func (s *HandlersServer) HandleRegRequests(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "POST":
		s.HandleRegRequestsPost(w, r)
	case "PUT":
		s.HandleRegRequestsPut(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleRegRequestsPost(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	if !user.IsAdmin {
		ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
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
		return
	}

	var req RegRequestPostRequest
	err = json.Unmarshal(reqJSON, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
		return
	}

	var regReqs []RegReq
	err = s.DB.Table("reg_reqs").
		Order("first_name, last_name").
		Offset(max(0, req.Offset)).
		Limit(min(max(0, req.Size), 50)).
		Find(&regReqs).
		Error
	if CheckServerError(w, err) {
		return
	}

	resp := RegRequestPostResponse{
		Requests: make([]RegRequestData, 0),
	}

	for _, regReq := range regReqs {
		resp.Requests = append(resp.Requests, RegRequestData{
			ID:        regReq.ID,
			FirstName: regReq.FirstName,
			LastName:  regReq.LastName,
			Phone:     regReq.Phone,
		})
	}

	ErrorMap(w, http.StatusOK, resp)
}

func (s *HandlersServer) HandleRegRequestsPut(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	if !user.IsAdmin {
		ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
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
		return
	}

	var req RegRequestPutRequest
	err = json.Unmarshal(reqJSON, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
		return
	}

	var cnt int64
	err = s.DB.Table("reg_reqs").Where("id = ?", req.ID).Count(&cnt).Error
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

	if !req.Accept {
		err = s.DB.
			Table("reg_reqs").
			Where("id = ?", req.ID).
			Delete(&RegReq{}).
			Error
		if CheckServerError(w, err) {
			return
		}
		return
	}

	var regReq RegReq
	err = s.DB.Table("reg_reqs").Where("id = ?", req.ID).Take(&regReq).Error
	if CheckServerError(w, err) {
		return
	}

	err = s.DB.Table("users").Save(&User{
		ID:           regReq.ID,
		FirstName:    regReq.FirstName,
		LastName:     regReq.LastName,
		PasswordHash: regReq.PasswordHash,
		Phone:        regReq.Phone,
	}).Error
	if CheckServerError(w, err) {
		return
	}

	w.WriteHeader(http.StatusOK)
}
