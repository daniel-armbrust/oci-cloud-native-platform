import re
import unicodedata
from typing import List, Optional
from uuid import uuid4

from fastapi import HTTPException

from app.repositories.pizza_repository import PizzaRepository

class PizzaService:
    def __init__(self, handle, settings):
        self.repo = PizzaRepository(handle, settings)

    def _default_slug(self, value: str) -> str:
        normalized = unicodedata.normalize("NFKD", value or "")
        ascii_value = normalized.encode("ascii", "ignore").decode()
        return re.sub(r"[^a-z0-9]+", "-", ascii_value.lower()).strip("-")

    def _normalize_pizza(self, pizza: dict) -> dict:
        raw_sizes = pizza.get("sizes") or []
        sizes = [
            {
                "size": item.get("size"),
                "slices": item.get("slices"),
                "price": float(item.get("price") or 0),
            }
            for item in raw_sizes
        ]
        prices = {item.get("size"): float(item.get("price") or 0) for item in raw_sizes}
        return {
            "id": pizza.get("id"),
            "slug": pizza.get("slug") or self._default_slug(pizza.get("name") or ""),
            "name": pizza.get("name") or "",
            "description": pizza.get("description") or "",
            "image_url": pizza.get("image_url") or "",
            "category": pizza.get("category") or "",
            "available": bool(pizza.get("available")),
            "sizes": sizes,
            "price_small": prices.get("pequena", 0),
            "price_medium": prices.get("media", 0),
            "price_large": prices.get("grande", 0),
        }

    def get_pizza(self, pizza_id: str) -> Optional[dict]:
        """
        Retorna uma pizza pelo ID
        """
        pizza = self.repo.get_pizza(pizza_id)

        if not pizza:
            return None

        return self._normalize_pizza(pizza)

    def list_pizzas(self, limit: int = 50) -> List[dict]:
        """
        Lista todas as pizzas
        """
        pizzas = self.repo.list_pizzas(limit)

        return [self._normalize_pizza(pizza) for pizza in pizzas]

    def list_by_category(self, category: str) -> List[dict]:
        """
        Lista pizzas por categoria
        """
        pizzas = self.repo.list_by_category(category)

        return pizzas

    def list_available(self) -> List[dict]:
        """
        Lista pizzas disponíveis
        """
        pizzas = self.repo.list_available()

        return pizzas

    def create_pizza(self, payload) -> dict:
        if self.repo.slug_exists(payload.slug):
            raise HTTPException(status_code=409, detail="Slug already in use")

        pizza_id = str(uuid4())
        return self._normalize_pizza(self.repo.save_pizza(pizza_id, payload))

    def update_pizza(self, pizza_id: str, payload) -> Optional[dict]:
        current = self.repo.get_pizza(pizza_id)

        if not current:
            return None

        if self.repo.slug_exists(payload.slug, exclude_id=pizza_id):
            raise HTTPException(status_code=409, detail="Slug already in use")

        return self._normalize_pizza(self.repo.save_pizza(pizza_id, payload))
