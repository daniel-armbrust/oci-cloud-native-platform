//
// user/internal/users/repository.go
//

package users

import (
	"context"
	"database/sql"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) List(ctx context.Context) ([]User, error) {
	rows, err := r.db.QueryContext(ctx, `SELECT id, name, email, created_at FROM users`)

	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var users []User

	for rows.Next() {
		var u User

		err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
		)

		if err != nil {
			return nil, err
		}

		users = append(users, u)
	}

	return users, nil
}

func (r *Repository) Get(ctx context.Context, id string) (*User, error) {
	var u User

	err := r.db.QueryRowContext(ctx, `
        SELECT id, name, email, created_at
        FROM users
        WHERE id = ?
    `, id).Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}

	if err != nil {
		return nil, err
	}

	return &u, nil
}

func (r *Repository) Create(ctx context.Context, u *User) error {
	_, err := r.db.ExecContext(ctx, `
        INSERT INTO users (id, name, email)
        VALUES (?, ?, ?)
    `,
		u.ID,
		u.Name,
		u.Email,
	)

	return err
}

func (r *Repository) Update(ctx context.Context, u *User) error {
	_, err := r.db.ExecContext(ctx, `
        UPDATE users
        SET name=?, email=?
        WHERE id=?
    `,
		u.Name,
		u.Email,
		u.ID,
	)

	return err
}

func (r *Repository) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `
        DELETE FROM users
        WHERE id=?
    `, id)

	return err
}