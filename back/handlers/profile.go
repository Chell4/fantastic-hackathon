package handlers

import (
	"net/http"
)

type ProfileResponse struct {
	FirstName   string  `json:"first_name"`
	SecondName  *string `json:"second_name"`
	LastName    string  `json:"last_name"`
	Phone       string  `json:"phone"`
	PicturePath *string `json:"picture_path"`
}

func (s *HandlersServer) HandleProfile(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	ErrorMap(w, http.StatusOK, ProfileResponse{
		FirstName:   user.FirstName,
		SecondName:  user.SecondName,
		LastName:    user.FirstName,
		Phone:       user.Phone,
		PicturePath: user.PicturePath,
	})
}
