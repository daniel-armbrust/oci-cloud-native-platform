#
# auth/app/store.py
#

import os
import time

import redis


class TokenStore:
    def __init__(self):
        self._client = redis.Redis(
            host=os.getenv("REDIS_HOST", "redis"),
            port=int(os.getenv("REDIS_PORT", "6379")),
            db=int(os.getenv("REDIS_DB", "0")),
            password=os.getenv("REDIS_PASSWORD") or None,
            decode_responses=True,
        )

    def _ttl(self, exp):
        return max(exp - int(time.time()), 1)

    def remember_refresh(self, payload):
        self._client.setex(
            f"auth:refresh:{payload['jti']}",
            self._ttl(payload["exp"]),
            payload["sub"],
        )

    def revoke(self, jti, exp):
        self._client.setex(f"auth:revoked:{jti}", self._ttl(exp), "1")
        self._client.delete(f"auth:refresh:{jti}")

    def is_revoked(self, jti):
        return bool(self._client.exists(f"auth:revoked:{jti}"))

    def has_refresh(self, jti):
        return bool(self._client.exists(f"auth:refresh:{jti}"))

    def ping(self):
        return self._client.ping()
