#
# pizza/schemas/pizza.py
#

from pydantic import BaseModel, Field
from typing import List
from datetime import datetime

class PizzaSize(BaseModel):
    size: str
    price: float


class Pizza(BaseModel):
    id: str
    name: str
    description: str
    image_url: str
    category: str
    available: bool
    sizes: List[PizzaSize]
    created_at: datetime
    updated_at: datetime

class PizzaResponse(BaseModel):
    status: str
    data: Pizza


class PizzaWritePayload(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    slug: str = Field(min_length=2, max_length=150)
    description: str = Field(min_length=4, max_length=500)
    category: str = Field(min_length=2, max_length=80)
    image_url: str = Field(min_length=3, max_length=255)
    available: bool
    price_small: float = Field(ge=0)
    price_medium: float = Field(ge=0)
    price_large: float = Field(ge=0)
