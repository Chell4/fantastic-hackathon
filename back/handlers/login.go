package handlers

import (
	"encoding/json"
	"io"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type LoginRequest struct {
	Phone    string `json:"phone"`
	Password string `json:"password"`
}

type LoginResponse struct {
	Token string `json:"token"`
}

func (s *HandlersServer) HandleLogin(w http.ResponseWriter, r *http.Request) {
	reqJSON, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
		return
	}

	var logReq LoginRequest
	err = json.Unmarshal(reqJSON, &logReq)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
		return
	}

	var cntUsers int64
	err = s.DB.Table("users").Where("phone_number = ?", logReq.Phone).Count(&cntUsers).Error
	if CheckServerError(w, err) {
		return
	}

	if cntUsers == 0 {
		ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
			"type":    "auth",
			"reason":  "login",
			"explain": ErrExplainLoginUserNotExists,
		})
		return
	}

	var user User
	err = s.DB.Table("users").Where("phone_numger = ?", logReq.Phone).First(&user).Error
	if CheckServerError(w, err) {
		return
	}

	err = bcrypt.CompareHashAndPassword(user.PasswordHash, []byte(logReq.Password))
	if err != nil {
		ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
			"type":    "auth",
			"reason":  "password",
			"explain": ErrExplainWrongPassword,
		})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": user.ID,
		"exp": time.Now().Add(24 * time.Hour),
	})

	tokenString, err := token.SignedString(user.PasswordHash)
	if CheckServerError(w, err) {
		return
	}

	resp := LoginResponse{
		Token: tokenString,
	}

	respJSON, err := json.Marshal(resp)
	if CheckServerError(w, err) {
		return
	}

	w.Write(respJSON)
}
