package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/robfig/cron/v3"
	"gorm.io/gorm"
)

const (
	ErrExplainCannotReadBody     = "Request body is not readable"
	ErrExplainInvalidJSON        = "Invlalid json schema"
	ErrExplainDatabaseErr        = "Error while interacting with database"
	ErrExplainPhoneExists        = "User with this phone already exists"
	ErrExplainUserPhoneNotExists = "User with this phone doesn't exist"
	ErrExplainInvalidPhotoURL    = "Sent photo url is not valid"
	ErrExplainWrongPassword      = "Wrong password"
	ErrExplainInvalidMedia       = "Invalid media path"
	ErrExplainNoPhone            = "No phone or empty"
	ErrExplainNoPassword         = "No password or empty"
	ErrExplainNoFirstName        = "No first name or empty"
	ErrExplainNoLastName         = "No last name or empty"
	ErrExplainMissingToken       = "Missing token"
	ErrExplainInvalidToken       = "Provided token is invalid"
	ErrExplainTokenExpired       = "Provided token expired"
)

const BcryptCost = 10

type HandlersServer struct {
	Address     string
	DB          *gorm.DB
	Cron        *cron.Cron
	CronProcess *cron.EntryID
}

type User struct {
	ID string `gorm:"primaryKey"`

	FirstName    string
	SecondName   *string
	LastName     string
	PasswordHash []byte
	Phone        string
	PicturePath  *string

	CreatedAt time.Time
	UpdatedAt time.Time
}

func ErrorMap(w http.ResponseWriter, code int, body interface{}) {
	bodyJSON, err := json.Marshal(body)
	if err != nil {
		log.Println(err)
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	http.Error(w, string(bodyJSON), code)
}

func CheckServerError(w http.ResponseWriter, err error) bool {
	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		log.Println(err)
		return true
	}
	return false
}

func (s *HandlersServer) ValidateToken(w http.ResponseWriter, r *http.Request) (*User, bool) {
	tokenStr := strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")

	if tokenStr == "" {
		ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
			"type":    "token",
			"reason":  "no_token",
			"explain": ErrExplainMissingToken,
		})
		return nil, false
	}

	var user *User

	_, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		expTime, err := token.Claims.GetExpirationTime()
		if err != nil {
			ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
				"type":    "token",
				"reason":  "invalid",
				"explain": ErrExplainInvalidToken,
			})
			return nil, err
		}
		if expTime.Time.Before(time.Now()) {
			ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
				"type":    "token",
				"reason":  "expired",
				"explain": ErrExplainTokenExpired,
			})
			return nil, err
		}

		id, err := token.Claims.GetSubject()
		if err != nil {
			ErrorMap(w, http.StatusUnauthorized, map[string]interface{}{
				"type":    "token",
				"reason":  "invalid",
				"explain": ErrExplainInvalidToken,
			})
			return nil, err
		}

		err = s.DB.Table("users").Where("id = ?", id).First(user).Error
		if CheckServerError(w, err) {
			return nil, err
		}

		return user.PasswordHash, nil
	})
	if err != nil {
		return nil, false
	}

	return user, true
}
