//
// user/internal/users/service.go
//

package users

import (
	"context"
)

type Service struct {
	repo *Repository
}

func NewService(r *Repository) *Service {
	return &Service{repo: r}
}

func (s *Service) List(ctx context.Context) ([]User, error) {
	return s.repo.List(ctx)
}

func (s *Service) Get(ctx context.Context, id string) (*User, error) {
	return s.repo.Get(ctx, id)
}

func (s *Service) Create(ctx context.Context, u *User) error {
	return s.repo.Create(ctx, u)
}

func (s *Service) Update(ctx context.Context, u *User) error {
	return s.repo.Update(ctx, u)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}