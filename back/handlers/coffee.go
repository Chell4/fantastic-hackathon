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
		s.DB.Table("coffee_matchs").Save(&CoffeeMatch{
			FirstID:  users[i].ID,
			SecondID: users[i+1].ID,

			MatchedAt: now,
		})
	}
	
	if len(users) % 2 == 	
}
