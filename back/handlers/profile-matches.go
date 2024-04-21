package handlers

import (
	"encoding/json"
	"io"
	"net/http"
)

type ProfileMatchesGetRequest struct {
	Offset int `json:"offset"`
	Size   int `json:"size"`
}

type ProfileMatchesData struct {
	ID string `json:"id"`

	MetAt     int64 `json:"met_at"`
	MeetTime  int64 `json:"meet_time"`
	MatchedAt int64 `json:"matched_at"`
}

type ProfileMatchesGetResponse struct {
	Matches   []ProfileMatchesData `json:"matches"`
	LastMatch int64                `json:"last_match"`
}

func (s *HandlersServer) HandleProfileMatches(w http.ResponseWriter, r *http.Request) {
	if enableCors(&w, r) {
		return
	}
	switch r.Method {
	case "GET":
		s.HandleProfileMatchesGet(w, r)
	default:
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
	}
}

func (s *HandlersServer) HandleProfileMatchesGet(w http.ResponseWriter, r *http.Request) {
	user, valid := s.ValidateToken(w, r)
	if !valid {
		return
	}

	reqBody, err := io.ReadAll(r.Body)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "body",
			"explain": ErrExplainCannotReadBody,
		})
		return
	}

	var req ProfileMatchesGetRequest
	err = json.Unmarshal(reqBody, &req)
	if err != nil {
		ErrorMap(w, http.StatusBadRequest, map[string]interface{}{
			"type":    "data",
			"reason":  "json",
			"explain": ErrExplainInvalidJSON,
		})
		return
	}

	var matches []CoffeeMatch
	err = s.DB.Table("coffee_matchs").
		Where("first_id = ?", user.ID).
		Or("second_id = ?", user.ID).
		Offset(max(req.Offset, 0)).
		Limit(min(50, max(req.Offset, 0))).
		Find(&matches).Error
	if CheckServerError(w, err) {
		return
	}

	lastMatch := int64(-1)
	if s.LastMatch != nil {
		lastMatch = s.LastMatch.Unix()
	}

	resp := ProfileMatchesGetResponse{
		Matches:   make([]ProfileMatchesData, 0),
		LastMatch: lastMatch,
	}
	for _, match := range matches {
		id := match.FirstID
		if id == user.ID {
			id = match.SecondID
		}

		metAt := int64(-1)
		if match.MetAt != nil {
			zz := *match.MetAt
			metAt = zz.Unix()
		}

		meetTime := int64(-1)
		if match.MeetTime != nil {
			zz := *match.MeetTime
			meetTime = int64(zz)
		}

		resp.Matches = append(resp.Matches, ProfileMatchesData{
			ID:        id,
			MetAt:     metAt,
			MeetTime:  meetTime,
			MatchedAt: match.MatchedAt.Unix(),
		})
	}

	ErrorMap(w, http.StatusOK, resp)
}
