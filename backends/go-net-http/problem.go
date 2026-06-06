package main

import (
	"encoding/json"
	"net/http"
)

// problem is an RFC 9457 problem detail.
type problem struct {
	Status int    `json:"status"`
	Title  string `json:"title"`
	Detail string `json:"detail"`
}

func writeProblem(w http.ResponseWriter, status int, detail string) {
	w.Header().Set("Content-Type", "application/problem+json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(problem{
		Status: status,
		Title:  http.StatusText(status),
		Detail: detail,
	})
}
