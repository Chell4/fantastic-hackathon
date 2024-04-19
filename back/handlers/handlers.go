package handlers

import (
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
)

type HandlersServer struct {
	Address  string
	DB       *gorm.DB
	JWTcache *cache.Cache
}

type User struct {
	ID string `gorm:"primaryKey,size:16"`

	FirstName  *string
	SecondName *string
	LastName   *string
	PictureUrl *string

	CreatedAt time.Time
	UpdatedAt time.Time
}
