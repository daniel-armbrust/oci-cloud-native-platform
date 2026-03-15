#
# pizza/app/main.py
#

import os

from fastapi import Depends, FastAPI, File, Form, Query, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from app.core.startup import init_services
from app.api.health import router as health_router
from app.schemas.pizza import PizzaWritePayload
from app.security import require_admin_payload
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.exceptions.handlers import (
    http_exception_handler,
    global_exception_handler,
)

from app.utils.jsend import success, fail

app = FastAPI(
    title="Pizza API",
    version="1.0.0"
)

allowed_origins = [
    origin.strip()
    for origin in os.getenv(
        "CORS_ALLOWED_ORIGINS",
        "http://localhost:8080,http://127.0.0.1:8080,http://localhost:8082,http://127.0.0.1:8082",
    ).split(",")
    if origin.strip()
]

if allowed_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Registrar exception handlers
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)

# Registrar routers
app.include_router(health_router)

@app.on_event("startup")
def startup():
    init_services(app)

@app.get("/pizzas/{pizza_id}")
def get_pizza(pizza_id: str, request: Request):
    service = request.app.state.service

    pizza = service.get_pizza(pizza_id)

    if not pizza:
        return fail({"message": "Pizza not found"}, 404)

    return success(pizza)

@app.get("/pizzas")
def list_pizzas(request: Request, limit: int = Query(50, ge=1, le=100)):
    service = request.app.state.service

    pizzas = service.list_pizzas(limit)

    return success(pizzas)


@app.post("/pizzas")
def create_pizza(payload: PizzaWritePayload, request: Request, _admin=Depends(require_admin_payload)):
    service = request.app.state.service
    pizza = service.create_pizza(payload)
    return success(pizza, 201)


@app.put("/pizzas/{pizza_id}")
def update_pizza(
    pizza_id: str,
    payload: PizzaWritePayload,
    request: Request,
    _admin=Depends(require_admin_payload),
):
    service = request.app.state.service

    pizza = service.update_pizza(pizza_id, payload)

    if not pizza:
        return fail({"message": "Pizza not found"}, 404)

    return success(pizza)


@app.post("/pizzas/upload-image")
async def upload_pizza_image(
    request: Request,
    image: UploadFile = File(...),
    slug: str = Form(default="pizza"),
    _admin=Depends(require_admin_payload),
):
    if not (image.content_type or "").startswith("image/"):
        return fail({"message": "Invalid image type"}, 400)

    content = await image.read()
    if not content:
        return fail({"message": "Empty image file"}, 400)

    storage = request.app.state.image_storage
    object_name = storage.build_object_name(slug, image.filename or "", image.content_type)
    storage.upload_image(object_name, content, image.content_type)

    return success({"image_url": object_name, "object_name": object_name}, 201)
