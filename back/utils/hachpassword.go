package utils

import (
	"log"
	"net/http"

	"golang.org/x/crypto/bcrypt"
)

func hash() {
	http.HandleFunc("/hash", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Метод не поддерживается", http.StatusMethodNotAllowed)
			return
		}

		password := r.FormValue("password")
		if password == "" {
			http.Error(w, "Пароль не указан", http.StatusBadRequest)
			return
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, "Ошибка при генерации хэша пароля", http.StatusInternalServerError)
			return
		}
		log.Println(w, "Хэш пароля: %s", string(hashedPassword))
	})

	log.Println("Сервер запущен на http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
