package handlers

import (
	"math/rand"
	"net/http"
	"time"
)

func (s *HandlersServer) HandleCoffee(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "POST":
		s.HandleCoffeePost(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleCoffeePost(w http.ResponseWriter, r *http.Request) {
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

	var users []User
	err := s.DB.Table("users").Where("is_ready", true).Find(&users).Error
	if CheckServerError(w, err) {
		return
	}

	now := time.Now()
	s.LastMatch = &now

	rand.Shuffle(len(users), func(i, j int) {
		tmp := users[i]
		users[i] = users[j]
		users[j] = tmp
	})

	for i := 0; i < len(users)-1; i += 2 {
		firstUser := users[i]
		secondUser := users[i+1]

		s.DB.Table("coffee_matchs").Save(&CoffeeMatch{
			FirstID:  firstUser.ID,
			SecondID: secondUser.ID,

			MatchedAt: now,
		})
		firstUser.LastMatch = &now
		secondUser.LastMatch = &now

		err = s.DB.Table("coffee_matchs").Save(&firstUser).Error
		if CheckServerError(w, err) {
			return
		}
		err = s.DB.Table("coffee_matchs").Save(&secondUser).Error
		if CheckServerError(w, err) {
			return
		}
	}
}
