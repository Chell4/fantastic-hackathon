package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type ScheduleRequest struct {
	Settings string `json:"settings"`
}

func (s *HandlersServer) HandleSchedule(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	switch r.Method {
	case "POST":
		s.HandleSchedulePost(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleSchedulePost(w http.ResponseWriter, r *http.Request) {
	var req ScheduleRequest

	body, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{})
		return
	}

	err = json.Unmarshal(body, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{})
		return
	}

	if s.CronProcess != nil {
		s.Cron.Remove(*s.CronProcess)
		s.CronProcess = nil
	}
	id, err := s.Cron.AddFunc(fmt.Sprintf("CRON_TZ=Europe/Moscow %v", req.Settings), func() {})
	if err != nil {
		CheckServerError(w, err)
		return
	}
	s.CronProcess = &id
}
