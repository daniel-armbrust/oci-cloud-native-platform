//
// user/cmd/api/main.go
//

package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"

	"user/internal/db"
	api "user/internal/http"
	"user/internal/users"
)

func getenv(key string) string {
	value := os.Getenv(key)
	if value == "" {
		log.Fatalf("missing environment variable %s", key)
	}
	return value
}

func main() {

	host := getenv("MYSQL_HOST")
	port := getenv("MYSQL_PORT")
	dbname := getenv("MYSQL_DATABASE")
	user := getenv("MYSQL_USER")
	password := getenv("MYSQL_PASSWORD")

	dsn := fmt.Sprintf(
		"%s:%s@tcp(%s:%s)/%s?parseTime=true",
		user,
		password,
		host,
		port,
		dbname,
	)

	database := db.NewMySQL(dsn)

	repo := users.NewRepository(database)
	service := users.NewService(repo)
	handler := users.NewHandler(service)

	r := chi.NewRouter()

	// 404 JSON
	r.NotFound(func(w http.ResponseWriter, r *http.Request) {
		api.WriteJSON(w, http.StatusNotFound, api.Fail("Resource not found"))
	})

	// 405 JSON
	r.MethodNotAllowed(func(w http.ResponseWriter, r *http.Request) {
		api.WriteJSON(w, http.StatusMethodNotAllowed, api.Fail("Method not allowed"))
	})

	// Routes
	r.Route("/users", func(r chi.Router) {

		r.Get("/", handler.List)
		r.Post("/", handler.Create)

		r.Route("/{id}", func(r chi.Router) {

			r.Get("/", handler.Get)
			r.Patch("/", handler.Update)
			r.Delete("/", handler.Delete)

		})
	})

	log.Println("user-service listening on :8080")

	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal(err)
	}
}