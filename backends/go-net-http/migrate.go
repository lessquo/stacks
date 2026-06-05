package main

import (
	"cmp"
	"database/sql"
	"embed"
	"fmt"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"
)

//go:embed migrations/*.sql
var migrations embed.FS

func runMigrations() error {
	db, err := sql.Open("pgx", dbDSN())
	if err != nil {
		return err
	}
	defer db.Close()

	goose.SetBaseFS(migrations)
	if err := goose.SetDialect("postgres"); err != nil {
		return err
	}
	return goose.Up(db, "migrations")
}

func dbDSN() string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		cmp.Or(os.Getenv("DB_HOST"), "localhost"),
		cmp.Or(os.Getenv("DB_PORT"), "5432"),
		cmp.Or(os.Getenv("DB_USER"), "stacks"),
		cmp.Or(os.Getenv("DB_PASSWORD"), "stacks"),
		cmp.Or(os.Getenv("DB_NAME"), "stacks"),
	)
}
