package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/robfig/cron/v3"
	"gorm.io/gorm"
)

const (
	ErrExplainCannotReadBody     = "Request body is not readable"
	ErrExplainInvalidJSON        = "Invlalid json schema"
	ErrExplainDatabaseErr        = "Error while interacting with database"
	ErrExplainUserExists         = "User with this login already exists"
	ErrExplainLoginUserNotExists = "User with this id doesn't exist"
	ErrExplainInvalidPhotoURL    = "Sent photo url is not valid"
	ErrExplainWrongPassword      = "Wrong password"
	ErrExplainInvalidMedia       = "Invalid media path"
)

func ErrorMap(w http.ResponseWriter, code int, body map[string]interface{}) {
	bodyJSON, err := json.Marshal(body)
	if err != nil {
		log.Println(err)
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	http.Error(w, string(bodyJSON), code)
}

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

func CheckServerError(w http.ResponseWriter, err error) bool {
	if err == nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		log.Println(err)
		return true
	}
	return false
}
