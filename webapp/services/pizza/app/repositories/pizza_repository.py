#
# pizza/app/repository/pizza_repository.py
#

from decimal import Decimal

from borneo import GetRequest, PutRequest, QueryRequest

class PizzaRepository:
    def __init__(self, handle, settings):
        self.handle = handle
        self.table_name = settings.TABLE_NAME
        self.compartment_id = settings.COMPARTMENT_ID

    def get_pizza(self, pizza_id: str):
        request = (
            GetRequest()
                .set_table_name(self.table_name)
                .set_compartment(self.compartment_id)
                .set_key({"id": pizza_id})
        )

        result = self.handle.get(request)

        return result.get_value()
    
    def list_pizzas(self, limit: int = 50):
        query = f"SELECT * FROM {self.table_name}"

        request = (
            QueryRequest()
            .set_statement(query)
            .set_compartment(self.compartment_id)
            .set_limit(limit)
        )

        result = self.handle.query(request)

        return result.get_results()

    def slug_exists(self, slug: str, exclude_id: str | None = None):
        request = (
            QueryRequest()
            .set_statement(f"SELECT * FROM {self.table_name}")
            .set_compartment(self.compartment_id)
            .set_limit(200)
        )

        rows = self.handle.query(request).get_results()
        normalized_slug = slug.strip().lower()

        for row in rows:
            row_slug = (row.get("slug") or "").strip().lower()
            row_id = row.get("id")
            if row_slug == normalized_slug and row_id != exclude_id:
                return True

        return False

    def save_pizza(self, pizza_id: str, payload):
        value = {
            "id": pizza_id,
            "slug": payload.slug.strip(),
            "name": payload.name.strip(),
            "description": payload.description.strip(),
            "category": payload.category.strip(),
            "image_url": payload.image_url.strip(),
            "available": payload.available,
            "sizes": [
                {"size": "pequena", "slices": 4, "price": Decimal(str(payload.price_small))},
                {"size": "media", "slices": 8, "price": Decimal(str(payload.price_medium))},
                {"size": "grande", "slices": 12, "price": Decimal(str(payload.price_large))},
            ],
        }

        request = (
            PutRequest()
            .set_table_name(self.table_name)
            .set_compartment(self.compartment_id)
            .set_value(value)
        )

        self.handle.put(request)
        return value
