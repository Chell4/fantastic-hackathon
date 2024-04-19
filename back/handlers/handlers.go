package handlers

import (
	"time"

	"gorm.io/gorm"
)

type HandlersServer struct {
	Address string
	DB      *gorm.DB
}

type User struct {
	ID string `gorm:"primaryKey,size:16"`

	FirstName  string
	SecondName *string
	LastName   string
	PictureUrl *string

	CreatedAt time.Time
	UpdatedAt time.Time
}
