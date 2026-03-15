#
# auth/app/security.py
#

import base64
import hashlib
import hmac
import json
import os
import time
import uuid


ACCESS_TOKEN_TTL = int(os.getenv("JWT_ACCESS_TTL", "3600"))
REFRESH_TOKEN_TTL = int(os.getenv("JWT_REFRESH_TTL", "604800"))


def _secret():
    return os.getenv("JWT_SECRET", "change-me-auth-secret").encode()


def _b64url_encode(data):
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def _b64url_decode(value):
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + padding)


def _sign(message):
    return hmac.new(_secret(), message.encode(), hashlib.sha256).digest()


def _encode(payload):
    header = {"alg": "HS256", "typ": "JWT"}
    encoded_header = _b64url_encode(
        json.dumps(header, separators=(",", ":")).encode()
    )
    encoded_payload = _b64url_encode(
        json.dumps(payload, separators=(",", ":")).encode()
    )
    signing_input = f"{encoded_header}.{encoded_payload}"
    signature = _b64url_encode(_sign(signing_input))
    return f"{signing_input}.{signature}"


def _decode(token):
    parts = token.split(".")

    if len(parts) != 3:
        raise ValueError("Invalid token format")

    signing_input = f"{parts[0]}.{parts[1]}"
    expected = _b64url_encode(_sign(signing_input))

    if not hmac.compare_digest(expected, parts[2]):
        raise ValueError("Invalid token signature")

    payload = json.loads(_b64url_decode(parts[1]))

    if payload.get("exp", 0) < int(time.time()):
        raise ValueError("Token expired")

    return payload


def create_access_token(user):
    now = int(time.time())
    payload = {
        "sub": user["id"],
        "email": user["email"],
        "role": user["role"],
        "type": "access",
        "iat": now,
        "exp": now + ACCESS_TOKEN_TTL,
        "jti": str(uuid.uuid4()),
    }
    return _encode(payload), ACCESS_TOKEN_TTL


def create_refresh_token(user):
    now = int(time.time())
    payload = {
        "sub": user["id"],
        "email": user["email"],
        "role": user["role"],
        "type": "refresh",
        "iat": now,
        "exp": now + REFRESH_TOKEN_TTL,
        "jti": str(uuid.uuid4()),
    }
    return _encode(payload), REFRESH_TOKEN_TTL


def decode_token(token):
    return _decode(token)
