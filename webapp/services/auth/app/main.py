#
# auth/app/main.py
#

import os

import bcrypt
from fastapi import FastAPI, Header
from fastapi.exceptions import RequestValidationError
from fastapi.responses import PlainTextResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from app.db import get_connection
from app.jsend import error, fail, success
from app.metrics import MetricsRegistry
from app.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
)
from app.store import TokenStore


class LoginRequest(BaseModel):
    email: str
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


app = FastAPI(title="Auth API", version="1.0.0")
app.state.metrics = MetricsRegistry()
app.state.tokens = TokenStore()


def get_allowed_origins():
    configured_origins = os.getenv("CORS_ALLOWED_ORIGINS")

    if configured_origins:
        return [origin.strip() for origin in configured_origins.split(",") if origin.strip()]

    return [
        "http://localhost:8082",
        "http://127.0.0.1:8082",
    ]


app.add_middleware(
    CORSMiddleware,
    allow_origins=get_allowed_origins(),
    allow_origin_regex=r"^https?://[^/]+:8082$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def authenticate_user(email, password):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, email, password_hash, role, active
            FROM users
            WHERE email = %s
            LIMIT 1
            """,
            (email,),
        )
        user = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    if not user or not user["active"]:
        return None

    if not bcrypt.checkpw(password.encode(), user["password_hash"].encode()):
        return None

    return user


def extract_bearer_token(authorization):
    if not authorization:
        return None

    parts = authorization.split(" ", 1)

    if len(parts) != 2 or parts[0].lower() != "bearer":
        return None

    return parts[1]


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    return error()


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    return fail("Invalid request payload", 400)


@app.get("/health")
def health():
    return success({"status": "ok"})


@app.get("/ready")
def ready():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        cursor.close()
        conn.close()
    except Exception:
        return fail("Database unavailable", 503)

    try:
        app.state.tokens.ping()
    except Exception:
        return fail("Redis unavailable", 503)

    return success({"status": "ready"})


@app.get("/metrics")
def metrics():
    return PlainTextResponse(
        content=app.state.metrics.render(),
        media_type="text/plain; version=0.0.4",
    )


@app.post("/auth")
def login(payload: LoginRequest):
    user = authenticate_user(payload.email, payload.password)

    if not user:
        app.state.metrics.increment("auth_login_fail_total")
        return fail("Invalid email or password", 401)

    access_token, expires_in = create_access_token(user)
    refresh_token, refresh_expires_in = create_refresh_token(user)
    refresh_payload = decode_token(refresh_token)
    app.state.tokens.remember_refresh(refresh_payload)
    app.state.metrics.increment("auth_login_success_total")

    return success(
        {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "Bearer",
            "expires_in": expires_in,
            "refresh_expires_in": refresh_expires_in,
        }
    )


@app.post("/auth/logout")
def logout(
    payload: RefreshRequest | None = None,
    authorization: str | None = Header(default=None),
):
    token = extract_bearer_token(authorization)

    if token:
        try:
            access_payload = decode_token(token)
            app.state.tokens.revoke(access_payload["jti"], access_payload["exp"])
        except Exception:
            return fail("Invalid access token", 401)

    if payload and payload.refresh_token:
        try:
            refresh_payload = decode_token(payload.refresh_token)
            app.state.tokens.revoke(refresh_payload["jti"], refresh_payload["exp"])
        except Exception:
            return fail("Invalid refresh token", 401)

    app.state.metrics.increment("auth_logout_total")
    return success({"message": "Logout successful"})


@app.post("/auth/refresh")
def refresh(payload: RefreshRequest):
    try:
        refresh_payload = decode_token(payload.refresh_token)
    except Exception:
        app.state.metrics.increment("auth_refresh_fail_total")
        return fail("Invalid refresh token", 401)

    if refresh_payload.get("type") != "refresh":
        app.state.metrics.increment("auth_refresh_fail_total")
        return fail("Invalid refresh token", 401)

    if app.state.tokens.is_revoked(refresh_payload["jti"]):
        app.state.metrics.increment("auth_refresh_fail_total")
        return fail("Invalid refresh token", 401)

    if not app.state.tokens.has_refresh(refresh_payload["jti"]):
        app.state.metrics.increment("auth_refresh_fail_total")
        return fail("Invalid refresh token", 401)

    user = {
        "id": refresh_payload["sub"],
        "email": refresh_payload["email"],
        "role": refresh_payload["role"],
    }

    access_token, expires_in = create_access_token(user)
    app.state.metrics.increment("auth_refresh_success_total")

    return success(
        {
            "access_token": access_token,
            "token_type": "Bearer",
            "expires_in": expires_in,
        }
    )
