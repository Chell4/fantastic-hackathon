package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

const dbInitSchema = `
	CREATE TABLE IF NOT EXISTS users (
		id uuid PRIMARY KEY
		login TEXT
		email TEXT
		pass_hash bytea
	);
`

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

	db.Exec(dbInitSchema)

	s := NewServer("localhost:8080", db)

	s.StartServer()
}
