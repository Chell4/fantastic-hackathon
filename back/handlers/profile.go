package handlers

import (
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

func (s *HandlersServer) HandleProfile(w http.ResponseWriter, r *http.Request) {
	tokenStr := strings.TrimPrefix(r.Header.Get("Autothorization"), "Bearer ")

	if tokenStr == "" {
		ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
			"type":    "token",
			"reason":  "no_token",
			"explain": ErrExplainMissingToken,
		})
		return
	}

	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) { return nil, nil })
	if err != nil {

	}
}
