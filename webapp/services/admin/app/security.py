import base64
import hashlib
import hmac
import json
import os
import time

from fastapi import Header, HTTPException, status


def _secret():
    return os.getenv("JWT_SECRET", "change-me-auth-secret").encode()


def _b64url_decode(value):
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + padding)


def decode_token(token):
    parts = token.split(".")

    if len(parts) != 3:
        raise ValueError("Invalid token format")

    signing_input = f"{parts[0]}.{parts[1]}"
    expected = base64.urlsafe_b64encode(
        hmac.new(_secret(), signing_input.encode(), hashlib.sha256).digest()
    ).rstrip(b"=").decode()

    if not hmac.compare_digest(expected, parts[2]):
        raise ValueError("Invalid token signature")

    payload = json.loads(_b64url_decode(parts[1]))

    if payload.get("exp", 0) < int(time.time()):
        raise ValueError("Token expired")

    return payload


def extract_bearer_token(authorization):
    if not authorization:
        return None

    parts = authorization.split(" ", 1)
    if len(parts) != 2 or parts[0].lower() != "bearer":
        return None

    return parts[1]


def require_admin_payload(authorization: str | None = Header(default=None)):
    token = extract_bearer_token(authorization)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token",
        )

    try:
        payload = decode_token(token)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc),
        ) from exc

    if payload.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type",
        )

    if payload.get("role") != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin role required",
        )

    return payload
