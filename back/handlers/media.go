package handlers

import (
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
)

func (s *HandlersServer) HandleMedia(w http.ResponseWriter, r *http.Request) {
	u, _ := url.Parse(r.URL.Path)
	picName := path.Base(u.Path)
	pic, err := os.ReadFile("../assets/" + picName)
	if err != nil {
		log.Fatalln("Failed read picture.", err)
	} else {
		w.Write(pic)
	}
}
