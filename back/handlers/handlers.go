package handlers

import (
	"gorm.io/gorm"
)

type HandlersServer struct {
	Address string
	DB      *gorm.DB
}
