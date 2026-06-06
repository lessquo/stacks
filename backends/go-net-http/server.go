package main

import (
	"cmp"
	"context"
	"log"
	"net/http"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/lessquo/stacks/go-net-http/internal/db"
)

func runServer() error {
	pool, err := pgxpool.New(context.Background(), dbDSN())
	if err != nil {
		return err
	}
	defer pool.Close()

	a := &api{q: db.New(pool)}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	mux.HandleFunc("POST /users", a.createUser)
	mux.HandleFunc("GET /users/{id}", a.getUser)

	addr := ":" + cmp.Or(os.Getenv("PORT"), "8080")
	log.Printf("listening on %s", addr)
	return http.ListenAndServe(addr, mux)
}
