package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	. "back/handlers"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println(err)
	}
	dsn := strings.ReplaceAll(fmt.Sprintf(
		`host=%v
		user=%v
		password=%v
		dbname=%v
		port=%v
		sslmode=disable
		TimeZone=Europe/Moscow`,
		os.Getenv("POSTGRES_HOST"),
		os.Getenv("POSTGRES_USER"),
		os.Getenv("POSTGRES_PASSWORD"),
		os.Getenv("POSTGRES_DB"),
		os.Getenv("POSTGRES_PORT"),
	), "\n", " ")

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalln("Unable to connect to db:", err)
	}

	err = db.AutoMigrate(&User{})
	if err != nil {
		log.Fatalln("Unable to automigrate db:", err)
	}

	err = db.Migrator().RenameTable(&User{}, "users")
	if err != nil {
		log.Fatalln("Unable to rename table:", err)
	}

	s := NewServer("localhost:8080", db)

	s.StartServer()
}
