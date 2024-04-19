package handlers

import (
	"log"
	"net/http"
	"time"

	"github.com/patrickmn/go-cache"
	"gorm.io/gorm"
)

const (
	ErrStatusCannotReadBody        = "Request body is not readable"
	ErrStatusInvalidJSON           = "Invlalid json schema"
	ErrStatusDatabaseErr           = "Error while interacting with database"
	ErrStatusUserExists            = "User with this login already exists"
	ErrStatusRegisterUserNotExists = "User with this id doesn't exist"
	ErrStatusInvalidPhotoURL       = "Sent photo url is invalid"
)

type HandlersServer struct {
	Address  string
	DB       *gorm.DB
	JWTcache *cache.Cache
}

type User struct {
	ID string `gorm:"primaryKey"`

	FirstName   *string
	SecondName  *string
	LastName    *string
	PhoneNumber *string
	Email       *string
	PicturePath *string

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
