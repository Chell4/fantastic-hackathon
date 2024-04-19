package handlers

import (
	"time"

	"github.com/patrickmn/go-cache"
	"gorm.io/gorm"
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
