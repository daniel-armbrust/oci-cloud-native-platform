//
// user/internal/users/handler.go
//

package users

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"

	api "user/internal/http"
)

type Handler struct {
	service *Service
}

func NewHandler(s *Service) *Handler {
	return &Handler{s}
}

func (h *Handler) List(w http.ResponseWriter, r *http.Request) {

	users, err := h.service.List(r.Context())

	if err != nil {
		api.WriteJSON(w, http.StatusInternalServerError, api.Error("Internal error"))
		return
	}

	api.WriteJSON(w, http.StatusOK, api.Success(users))
}

func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {

	id := chi.URLParam(r, "id")

	user, err := h.service.Get(r.Context(), id)

	if err != nil {
		api.WriteJSON(w, http.StatusInternalServerError, api.Error("Internal error"))
		return
	}

	if user == nil {
		api.WriteJSON(w, http.StatusNotFound, api.Fail("User not found"))
		return
	}

	api.WriteJSON(w, http.StatusOK, api.Success(user))
}

func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {

	var u User

	if err := json.NewDecoder(r.Body).Decode(&u); err != nil {
		api.WriteJSON(w, http.StatusBadRequest, api.Fail("Invalid request body"))
		return
	}

	err := h.service.Create(r.Context(), &u)

	if err != nil {
		api.WriteJSON(w, http.StatusBadRequest, api.Fail("Could not create user"))
		return
	}

	api.WriteJSON(w, http.StatusCreated, api.Success(u))
}

func (h *Handler) Update(w http.ResponseWriter, r *http.Request) {

	id := chi.URLParam(r, "id")

	var u User

	if err := json.NewDecoder(r.Body).Decode(&u); err != nil {
		api.WriteJSON(w, http.StatusBadRequest, api.Fail("Invalid request body"))
		return
	}

	u.ID = id

	err := h.service.Update(r.Context(), &u)

	if err != nil {
		api.WriteJSON(w, http.StatusBadRequest, api.Fail("Could not update user"))
		return
	}

	api.WriteJSON(w, http.StatusOK, api.Success(u))
}

func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {

	id := chi.URLParam(r, "id")

	err := h.service.Delete(r.Context(), id)

	if err != nil {
		api.WriteJSON(w, http.StatusInternalServerError, api.Error("Could not delete user"))
		return
	}

	api.WriteJSON(w, http.StatusOK, api.Success("User deleted"))
}