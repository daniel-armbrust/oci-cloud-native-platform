from collections import defaultdict
from decimal import Decimal
import os
from uuid import UUID, uuid4

import bcrypt
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import HTMLResponse
from pydantic import BaseModel, Field
from borneo import GetRequest, PutRequest, QueryRequest

from app.core.templates import templates
from app.db import get_connection
from app.nosql import get_compartment_id, get_nosql_handle, get_pizzas_table_name
from app.security import require_admin_payload

router = APIRouter()


class UpdateUserPayload(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    email: str = Field(min_length=5, max_length=255)
    role: str
    whatsapp: str | None = Field(default=None, max_length=20)
    active: bool
    password: str | None = Field(default=None, min_length=8, max_length=72)


class CreateUserPayload(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    email: str = Field(min_length=5, max_length=255)
    role: str
    whatsapp: str | None = Field(default=None, max_length=20)
    active: bool
    password: str = Field(min_length=8, max_length=72)


class UpdateDeliveryZonePayload(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    city: str | None = Field(default=None, max_length=150)
    state: str | None = Field(default=None, max_length=50)
    neighborhood: str | None = Field(default=None, max_length=150)
    delivery_fee: float
    active: bool


class UpdatePizzaPayload(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    slug: str = Field(min_length=2, max_length=150)
    description: str = Field(min_length=4, max_length=500)
    category: str = Field(min_length=2, max_length=80)
    image_url: str = Field(min_length=3, max_length=255)
    available: bool
    price_small: float
    price_medium: float
    price_large: float


class CreatePizzaPayload(UpdatePizzaPayload):
    pass


def _require_uuid(value, label):
    try:
        UUID(value)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=f"Invalid {label}") from exc


def _normalize_user(row):
    return {
        "id": row["id"],
        "name": row["name"],
        "email": row["email"],
        "role": row["role"],
        "whatsapp": row.get("whatsapp") or "",
        "active": bool(row["active"]),
        "created_at": row["created_at"].isoformat() if row.get("created_at") else "",
        "updated_at": row["updated_at"].isoformat() if row.get("updated_at") else "",
    }


def _normalize_zone(row):
    return {
        "id": row["id"],
        "name": row["name"],
        "city": row.get("city") or "",
        "state": row.get("state") or "",
        "neighborhood": row.get("neighborhood") or "",
        "delivery_fee": float(row.get("delivery_fee") or 0),
        "active": bool(row["active"]),
    }


def _normalize_pizza(row):
    sizes = row.get("sizes") or []
    prices = {item.get("size"): float(item.get("price") or 0) for item in sizes}
    return {
        "id": row["id"],
        "slug": row.get("slug") or "",
        "name": row.get("name") or "",
        "description": row.get("description") or "",
        "category": row.get("category") or "",
        "image_url": row.get("image_url") or "",
        "available": bool(row.get("available")),
        "price_small": prices.get("pequena", 0),
        "price_medium": prices.get("media", 0),
        "price_large": prices.get("grande", 0),
    }


def _build_pizza_value(pizza_id, payload):
    return {
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


@router.get("/admin/users", response_class=HTMLResponse)
def users_page(request: Request):
    return templates.TemplateResponse("users.html", {"request": request})


@router.get("/admin/users/{user_id}", response_class=HTMLResponse)
def user_detail_page(request: Request, user_id: str):
    return templates.TemplateResponse(
        "user_detail.html",
        {"request": request, "user_id": user_id},
    )


@router.get("/admin/delivery-zones", response_class=HTMLResponse)
def delivery_zones_page(request: Request):
    return templates.TemplateResponse("delivery_zones.html", {"request": request})


@router.get("/admin/delivery-zones/{zone_id}", response_class=HTMLResponse)
def delivery_zone_detail_page(request: Request, zone_id: str):
    return templates.TemplateResponse(
        "delivery_zone_detail.html",
        {"request": request, "zone_id": zone_id},
    )


@router.get("/admin/cardapio", response_class=HTMLResponse)
def menu_page(request: Request):
    image_base_url = ""
    namespace = (os.getenv("OBJECT_STORAGE_NAMESPACE") or "").strip()
    region = (os.getenv("OCI_REGION") or "").strip()
    bucket = os.getenv("BUCKET_PIZZAS_IMG", "pizzas-img").strip()
    if namespace and region and bucket:
        image_base_url = f"https://objectstorage.{region}.oraclecloud.com/n/{namespace}/b/{bucket}/o"

    return templates.TemplateResponse(
        "menu.html",
        {
            "request": request,
            "pizza_api_base_url": os.getenv("PIZZA_API_BASE_URL", "http://localhost:8083"),
            "pizza_image_base_url": image_base_url,
        },
    )


@router.get("/admin/cardapio/{pizza_id}", response_class=HTMLResponse)
def pizza_detail_page(request: Request, pizza_id: str):
    image_base_url = ""
    namespace = (os.getenv("OBJECT_STORAGE_NAMESPACE") or "").strip()
    region = (os.getenv("OCI_REGION") or "").strip()
    bucket = os.getenv("BUCKET_PIZZAS_IMG", "pizzas-img").strip()
    if namespace and region and bucket:
        image_base_url = f"https://objectstorage.{region}.oraclecloud.com/n/{namespace}/b/{bucket}/o"

    return templates.TemplateResponse(
        "pizza_detail.html",
        {
            "request": request,
            "pizza_id": pizza_id,
            "pizza_api_base_url": os.getenv("PIZZA_API_BASE_URL", "http://localhost:8083"),
            "pizza_image_base_url": image_base_url,
        },
    )


@router.get("/api/admin/users")
def list_users(_admin=Depends(require_admin_payload)):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, name, email, role, whatsapp, active, created_at, updated_at
            FROM users
            ORDER BY created_at DESC, name ASC
            """
        )
        users = [_normalize_user(row) for row in cursor.fetchall()]
    finally:
        cursor.close()
        conn.close()

    return {"status": "success", "data": users}


@router.post("/api/admin/users")
def create_user(payload: CreateUserPayload, _admin=Depends(require_admin_payload)):
    if payload.role not in {"admin", "user"}:
        raise HTTPException(status_code=400, detail="Invalid role")

    if "@" not in payload.email or "." not in payload.email.split("@")[-1]:
        raise HTTPException(status_code=400, detail="Invalid email")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT id FROM users WHERE email=%s LIMIT 1",
            (payload.email.strip().lower(),),
        )
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="Email already in use")

        user_id = str(uuid4())
        password_hash = bcrypt.hashpw(payload.password.encode(), bcrypt.gensalt()).decode()

        cursor.execute(
            """
            INSERT INTO users (id, name, email, password_hash, role, whatsapp, active)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                user_id,
                payload.name.strip(),
                payload.email.strip().lower(),
                password_hash,
                payload.role,
                (payload.whatsapp or "").strip() or None,
                payload.active,
            ),
        )
        conn.commit()

        cursor.execute(
            """
            SELECT id, name, email, role, whatsapp, active, created_at, updated_at
            FROM users
            WHERE id=%s
            LIMIT 1
            """,
            (user_id,),
        )
        user = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    return {"status": "success", "data": _normalize_user(user)}


@router.get("/api/admin/users/{user_id}")
def get_user_detail(user_id: str, _admin=Depends(require_admin_payload)):
    _require_uuid(user_id, "user id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, name, email, role, whatsapp, active, created_at, updated_at
            FROM users
            WHERE id=%s
            LIMIT 1
            """,
            (user_id,),
        )
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="User not found")

        user = _normalize_user(row)

        cursor.execute(
            """
            SELECT id, street, number, complement, neighborhood, city, state, zip_code, is_default, created_at
            FROM user_addresses
            WHERE user_id=%s
            ORDER BY is_default DESC, created_at DESC
            """,
            (user_id,),
        )
        addresses = [
            {
                "id": item["id"],
                "street": item["street"],
                "number": item.get("number") or "",
                "complement": item.get("complement") or "",
                "neighborhood": item.get("neighborhood") or "",
                "city": item.get("city") or "",
                "state": item.get("state") or "",
                "zip_code": item.get("zip_code") or "",
                "is_default": bool(item["is_default"]),
                "created_at": item["created_at"].isoformat() if item.get("created_at") else "",
            }
            for item in cursor.fetchall()
        ]

        cursor.execute(
            """
            SELECT
                o.id,
                o.status,
                o.total_amount,
                o.created_at,
                o.updated_at,
                ua.street,
                ua.number,
                ua.neighborhood,
                ua.city,
                ua.state
            FROM orders o
            JOIN user_addresses ua ON ua.id = o.address_id
            WHERE o.user_id=%s
            ORDER BY o.created_at DESC
            """,
            (user_id,),
        )
        orders = []
        order_ids = []
        for item in cursor.fetchall():
            order_ids.append(item["id"])
            orders.append(
                {
                    "id": item["id"],
                    "status": item["status"],
                    "total_amount": float(item.get("total_amount") or 0),
                    "created_at": item["created_at"].isoformat() if item.get("created_at") else "",
                    "updated_at": item["updated_at"].isoformat() if item.get("updated_at") else "",
                    "delivery_address": ", ".join(
                        [
                            part
                            for part in [
                                item.get("street"),
                                item.get("number"),
                                item.get("neighborhood"),
                                item.get("city"),
                                item.get("state"),
                            ]
                            if part
                        ]
                    ),
                    "items": [],
                }
            )

        items_by_order = defaultdict(list)
        if order_ids:
            placeholders = ", ".join(["%s"] * len(order_ids))
            cursor.execute(
                f"""
                SELECT order_id, pizza_name, size, price, quantity
                FROM order_items
                WHERE order_id IN ({placeholders})
                ORDER BY created_at ASC
                """,
                tuple(order_ids),
            )
            for item in cursor.fetchall():
                items_by_order[item["order_id"]].append(
                    {
                        "pizza_name": item.get("pizza_name") or "",
                        "size": item.get("size") or "",
                        "price": float(item.get("price") or 0),
                        "quantity": int(item.get("quantity") or 0),
                    }
                )

        for order in orders:
            order["items"] = items_by_order[order["id"]]
    finally:
        cursor.close()
        conn.close()

    return {"status": "success", "data": {"user": user, "addresses": addresses, "orders": orders}}


@router.put("/api/admin/users/{user_id}")
def update_user(user_id: str, payload: UpdateUserPayload, _admin=Depends(require_admin_payload)):
    _require_uuid(user_id, "user id")

    if payload.role not in {"admin", "user"}:
        raise HTTPException(status_code=400, detail="Invalid role")

    if "@" not in payload.email or "." not in payload.email.split("@")[-1]:
        raise HTTPException(status_code=400, detail="Invalid email")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM users WHERE id=%s LIMIT 1", (user_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="User not found")

        cursor.execute(
            "SELECT id FROM users WHERE email=%s AND id<>%s LIMIT 1",
            (payload.email.strip().lower(), user_id),
        )
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="Email already in use")

        if payload.password:
            password_hash = bcrypt.hashpw(payload.password.encode(), bcrypt.gensalt()).decode()
            cursor.execute(
                """
                UPDATE users
                SET name=%s, email=%s, role=%s, whatsapp=%s, active=%s, password_hash=%s
                WHERE id=%s
                """,
                (
                    payload.name.strip(),
                    payload.email.strip().lower(),
                    payload.role,
                    (payload.whatsapp or "").strip() or None,
                    payload.active,
                    password_hash,
                    user_id,
                ),
            )
        else:
            cursor.execute(
                """
                UPDATE users
                SET name=%s, email=%s, role=%s, whatsapp=%s, active=%s
                WHERE id=%s
                """,
                (
                    payload.name.strip(),
                    payload.email.strip().lower(),
                    payload.role,
                    (payload.whatsapp or "").strip() or None,
                    payload.active,
                    user_id,
                ),
            )

        conn.commit()
        cursor.execute(
            """
            SELECT id, name, email, role, whatsapp, active, created_at, updated_at
            FROM users
            WHERE id=%s
            LIMIT 1
            """,
            (user_id,),
        )
        user = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    return {"status": "success", "data": _normalize_user(user)}


@router.get("/api/admin/delivery-zones")
def list_delivery_zones(_admin=Depends(require_admin_payload)):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, name, city, state, neighborhood, delivery_fee, active
            FROM delivery_zones
            ORDER BY active DESC, city ASC, neighborhood ASC, name ASC
            """
        )
        zones = [_normalize_zone(item) for item in cursor.fetchall()]
    finally:
        cursor.close()
        conn.close()

    return {"status": "success", "data": zones}


@router.get("/api/admin/delivery-zones/{zone_id}")
def get_delivery_zone_detail(zone_id: str, _admin=Depends(require_admin_payload)):
    _require_uuid(zone_id, "delivery zone id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, name, city, state, neighborhood, delivery_fee, active
            FROM delivery_zones
            WHERE id=%s
            LIMIT 1
            """,
            (zone_id,),
        )
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Delivery zone not found")
    finally:
        cursor.close()
        conn.close()

    return {"status": "success", "data": _normalize_zone(row)}


@router.get("/api/admin/pizzas")
def list_pizzas(_admin=Depends(require_admin_payload)):
    handle = get_nosql_handle()
    request = (
        QueryRequest()
        .set_statement(f"SELECT * FROM {get_pizzas_table_name()}")
        .set_compartment(get_compartment_id())
        .set_limit(100)
    )
    result = handle.query(request)
    pizzas = [_normalize_pizza(item) for item in result.get_results()]
    pizzas.sort(key=lambda item: item["name"].lower())
    return {"status": "success", "data": pizzas}


@router.get("/api/admin/pizzas/{pizza_id}")
def get_pizza_detail(pizza_id: str, _admin=Depends(require_admin_payload)):
    _require_uuid(pizza_id, "pizza id")

    handle = get_nosql_handle()
    request = (
        GetRequest()
        .set_table_name(get_pizzas_table_name())
        .set_compartment(get_compartment_id())
        .set_key({"id": pizza_id})
    )
    pizza = handle.get(request).get_value()
    if not pizza:
        raise HTTPException(status_code=404, detail="Pizza not found")

    return {"status": "success", "data": _normalize_pizza(pizza)}


@router.post("/api/admin/pizzas")
def create_pizza(payload: CreatePizzaPayload, _admin=Depends(require_admin_payload)):
    handle = get_nosql_handle()
    table_name = get_pizzas_table_name()
    compartment_id = get_compartment_id()

    query_request = (
        QueryRequest()
        .set_statement(f"SELECT id, slug FROM {table_name}")
        .set_compartment(compartment_id)
        .set_limit(200)
    )
    existing = handle.query(query_request).get_results()
    normalized_slug = payload.slug.strip().lower()
    if any((item.get("slug") or "").strip().lower() == normalized_slug for item in existing):
        raise HTTPException(status_code=409, detail="Slug already in use")

    pizza_id = str(uuid4())
    created = _build_pizza_value(pizza_id, payload)

    put_request = (
        PutRequest()
        .set_table_name(table_name)
        .set_compartment(compartment_id)
        .set_value(created)
    )
    handle.put(put_request)

    return {"status": "success", "data": _normalize_pizza(created)}


@router.put("/api/admin/delivery-zones/{zone_id}")
def update_delivery_zone(zone_id: str, payload: UpdateDeliveryZonePayload, _admin=Depends(require_admin_payload)):
    _require_uuid(zone_id, "delivery zone id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM delivery_zones WHERE id=%s LIMIT 1", (zone_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Delivery zone not found")

        cursor.execute(
            """
            UPDATE delivery_zones
            SET name=%s, city=%s, state=%s, neighborhood=%s, delivery_fee=%s, active=%s
            WHERE id=%s
            """,
            (
                payload.name.strip(),
                (payload.city or "").strip() or None,
                (payload.state or "").strip() or None,
                (payload.neighborhood or "").strip() or None,
                payload.delivery_fee,
                payload.active,
                zone_id,
            ),
        )
        conn.commit()

        cursor.execute(
            """
            SELECT id, name, city, state, neighborhood, delivery_fee, active
            FROM delivery_zones
            WHERE id=%s
            LIMIT 1
            """,
            (zone_id,),
        )
        zone = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    return {"status": "success", "data": _normalize_zone(zone)}


@router.put("/api/admin/pizzas/{pizza_id}")
def update_pizza(pizza_id: str, payload: UpdatePizzaPayload, _admin=Depends(require_admin_payload)):
    _require_uuid(pizza_id, "pizza id")

    handle = get_nosql_handle()
    table_name = get_pizzas_table_name()
    compartment_id = get_compartment_id()

    get_request = (
        GetRequest()
        .set_table_name(table_name)
        .set_compartment(compartment_id)
        .set_key({"id": pizza_id})
    )
    existing = handle.get(get_request).get_value()
    if not existing:
        raise HTTPException(status_code=404, detail="Pizza not found")

    updated = dict(existing)
    updated.update(_build_pizza_value(pizza_id, payload))

    put_request = (
        PutRequest()
        .set_table_name(table_name)
        .set_compartment(compartment_id)
        .set_value(updated)
    )
    handle.put(put_request)

    return {"status": "success", "data": _normalize_pizza(updated)}
