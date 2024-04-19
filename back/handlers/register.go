package handlers

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
)

const BcryptCost = 10

type RegisterRequest struct {
	GoogleID string `json:"google_id"`

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
	s.DB.Where("google_id = ?", resp.GoogleID).Count(&cnt)
	if cnt == 0 {
		log.Fatalln("User with this ID doesn`t exist.")
	} else {
		s.DB.Model(&User{}).Where("google_id = ?", resp.GoogleID).Updates(User{
			FirstName:   &resp.FirstName,
			SecondName:  &resp.SecondName,
			LastName:    &resp.LastName,
			PicturePath: &resp.PicturePath,
		})
	}
}
