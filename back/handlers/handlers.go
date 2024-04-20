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
	ErrExplainPhoneExists        = "User with this phone already exists"
	ErrExplainUserPhoneNotExists = "User with this phone doesn't exist"
	ErrExplainInvalidPhotoURL    = "Sent photo url is not valid"
	ErrExplainWrongPassword      = "Wrong password"
	ErrExplainInvalidMedia       = "Invalid media path"
	ErrExplainNoPhone            = "No phone or empty"
	ErrExplainNoPassword         = "No password or empty"
	ErrExplainNoFirstName        = "No first name or empty"
	ErrExplainNoLastName         = "No last name or empty"
)

func WriteHeadersForFront(w http.ResponseWriter) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Credentials", "true")
	w.Header().Add(
		"Access-Control-Allow-Headers",
		"Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
	)
	w.Header().Add("Access-Control-Allow-Methods", "POST, OPTIONS")
}

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
	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		log.Println(err)
		return true
	}
	return false
}
