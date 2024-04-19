package handlers

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
)

type RegisterRequest struct {
	Email       string `json:"email"`
	Password    string `json:"password"`
	PhoneNumber string `json:"phone_number"`
	FirstName   string `json:"first_name"`
	SecondName  string `json:"second_name"`
	LastName    string `json:"last_name"`
	PicturePath string `json:"picture_path"`
}

type RegisterResponse struct {
}

func (s *HandlersServer) HandleRegister(w http.ResponseWriter, r *http.Request) {
	var resp RegisterRequest

	body, err := io.ReadAll(r.Body)
	if err != nil {
		log.Fatalln("Enable to read data: ", err)
	} else {
		err = json.Unmarshal(body, &resp)
		if err != nil {
			log.Fatalln("Enable to convert data to json: ", err)
		}
	}
	var cnt int64
	s.DB.Where("google_id = ?", resp.ID).Count(&cnt)
	if cnt == 0 {
		log.Fatalln("User with this ID doesn`t exist.")
	} else {
		s.DB.Model(&User{}).Where("google_id = ?", resp.ID).Updates(User{
			Email:       &resp.Email,
			PhoneNumber: &resp.PhoneNumber,
			FirstName:   &resp.FirstName,
			SecondName:  &resp.SecondName,
			LastName:    &resp.LastName,
			PicturePath: &resp.PicturePath,
		})
	}
}
