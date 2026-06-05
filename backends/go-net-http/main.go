package main

import (
	"log"
	"os"
)

func main() {
	var err error
	if len(os.Args) > 1 && os.Args[1] == "migrate" {
		err = runMigrations()
	} else {
		err = runServer()
	}
	if err != nil {
		log.Fatal(err)
	}
}
