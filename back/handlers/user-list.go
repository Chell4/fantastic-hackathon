package handlers

import (
	"encoding/json"
	"io"
	"net/http"
)

type UserListGetRequest struct {
	Offset int `json:"offset"`
	Size   int `json:"size"`
}

type UserListData struct {
	ID         string `json:"id"`
	FirstName  string `json:"first_name"`
	SecondName string `json:"second_name"`
	LastName   string `json:"last_name"`
	Phone      string `json:"phone"`
	IsAdmin    bool   `json:"is_admin"`
}

type UserListGetResponse struct {
	UserList []UserListData `json:"users"`
}

func (s *HandlersServer) HandleUserList(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "GET":
		s.HandleUserListGet(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleUserListGet(w http.ResponseWriter, r *http.Request) {
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

	reqBody, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
		return
	}

	var req UserListGetRequest
	err = json.Unmarshal(reqBody, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
		return
	}

	var users []User
	err = s.DB.Table("users").Offset(max(req.Offset, 0)).Limit(min(max(req.Size, 0), 50)).Find(&users).Error
	if CheckServerError(w, err) {
		return
	}

	resp := UserListGetResponse{
		UserList: make([]UserListData, 0),
	}

	for _, user := range users {
		resp.UserList = append(resp.UserList, UserListData{
			ID:        user.ID,
			FirstName: user.FirstName,
			SecondName: func() string {
				if user.SecondName == nil {
					return ""
				}
				return *user.SecondName
			}(),
			LastName: user.LastName,
			Phone:    user.Phone,
			IsAdmin:  user.IsAdmin,
		})
	}

	respJSON, err := json.Marshal(resp)
	if CheckServerError(w, err) {
		return
	}

	w.WriteHeader(http.StatusOK)
	_, err = w.Write(respJSON)
	if CheckServerError(w, err) {
		return
	}
}
