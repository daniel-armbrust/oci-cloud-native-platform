//
// user/internal/db/mysql.go
//

package db

import (
	"database/sql"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

func NewMySQL(dsn string) *sql.DB {
	db, err := sql.Open("mysql", dsn)
	
	if err != nil {
		log.Fatal(err)
	}

	if err := db.Ping(); err != nil {
		log.Fatal(err)
	}

	return db
}