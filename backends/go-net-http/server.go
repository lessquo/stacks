package main

import (
	"cmp"
	"log"
	"net/http"
	"os"
)

func runServer() error {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	addr := ":" + cmp.Or(os.Getenv("PORT"), "8080")
	log.Printf("listening on %s", addr)
	return http.ListenAndServe(addr, mux)
}
