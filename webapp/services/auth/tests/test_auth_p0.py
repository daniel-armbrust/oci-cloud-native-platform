from fastapi.testclient import TestClient

from app.metrics import MetricsRegistry
from app import main as main_module


class FakeTokenStore:
    def __init__(self):
        self.remembered = []
        self.revoked = []
        self.revoked_jtis = set()
        self.refresh_jtis = set()
        self.ping_ok = True

    def remember_refresh(self, payload):
        self.remembered.append(payload)
        self.refresh_jtis.add(payload["jti"])

    def revoke(self, jti, exp):
        self.revoked.append((jti, exp))
        self.revoked_jtis.add(jti)
        self.refresh_jtis.discard(jti)

    def is_revoked(self, jti):
        return jti in self.revoked_jtis

    def has_refresh(self, jti):
        return jti in self.refresh_jtis

    def ping(self):
        if not self.ping_ok:
            raise RuntimeError("redis unavailable")
        return True


class FakeCursor:
    def execute(self, _query):
        return None

    def fetchone(self):
        return 1

    def close(self):
        return None


class FakeConnection:
    def cursor(self):
        return FakeCursor()

    def close(self):
        return None


def _make_client():
    main_module.app.state.metrics = MetricsRegistry()
    main_module.app.state.tokens = FakeTokenStore()
    return TestClient(main_module.app)


def test_login_success_returns_tokens(monkeypatch):
    client = _make_client()

    monkeypatch.setattr(
        main_module,
        "authenticate_user",
        lambda _email, _password: {
            "id": "user-1",
            "email": "admin@ocipizza.com",
            "role": "admin",
        },
    )
    monkeypatch.setattr(main_module, "create_access_token", lambda _user: ("access.jwt", 3600))
    monkeypatch.setattr(main_module, "create_refresh_token", lambda _user: ("refresh.jwt", 604800))
    monkeypatch.setattr(
        main_module,
        "decode_token",
        lambda _token: {"jti": "refresh-jti-1", "exp": 9999999999, "sub": "user-1"},
    )

    response = client.post(
        "/auth",
        json={"email": "admin@ocipizza.com", "password": "admin123"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "success"
    assert body["data"]["access_token"] == "access.jwt"
    assert body["data"]["refresh_token"] == "refresh.jwt"
    assert body["data"]["token_type"] == "Bearer"
    assert body["data"]["expires_in"] == 3600


def test_login_invalid_credentials_returns_401(monkeypatch):
    client = _make_client()
    monkeypatch.setattr(main_module, "authenticate_user", lambda _email, _password: None)

    response = client.post(
        "/auth",
        json={"email": "admin@ocipizza.com", "password": "wrong"},
    )

    assert response.status_code == 401
    assert response.json() == {"status": "fail", "message": "Invalid email or password"}


def test_login_invalid_payload_returns_400():
    client = _make_client()

    response = client.post("/auth", json={"email": "admin@ocipizza.com"})

    assert response.status_code == 400
    assert response.json() == {"status": "fail", "message": "Invalid request payload"}


def test_refresh_success_with_valid_refresh_token(monkeypatch):
    client = _make_client()
    token_store = main_module.app.state.tokens
    token_store.refresh_jtis.add("refresh-jti-1")

    monkeypatch.setattr(
        main_module,
        "decode_token",
        lambda _token: {
            "sub": "user-1",
            "email": "admin@ocipizza.com",
            "role": "admin",
            "type": "refresh",
            "jti": "refresh-jti-1",
            "exp": 9999999999,
        },
    )
    monkeypatch.setattr(main_module, "create_access_token", lambda _user: ("new.access.jwt", 3600))

    response = client.post("/auth/refresh", json={"refresh_token": "refresh.jwt"})

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "success"
    assert body["data"]["access_token"] == "new.access.jwt"
    assert body["data"]["expires_in"] == 3600


def test_refresh_with_access_token_type_returns_401(monkeypatch):
    client = _make_client()

    monkeypatch.setattr(
        main_module,
        "decode_token",
        lambda _token: {
            "sub": "user-1",
            "email": "admin@ocipizza.com",
            "role": "admin",
            "type": "access",
            "jti": "access-jti-1",
            "exp": 9999999999,
        },
    )

    response = client.post("/auth/refresh", json={"refresh_token": "access.jwt"})

    assert response.status_code == 401
    assert response.json() == {"status": "fail", "message": "Invalid refresh token"}


def test_logout_with_access_token_revokes_token(monkeypatch):
    client = _make_client()
    token_store = main_module.app.state.tokens

    monkeypatch.setattr(
        main_module,
        "decode_token",
        lambda _token: {"jti": "access-jti-1", "exp": 9999999999},
    )

    response = client.post(
        "/auth/logout",
        headers={"Authorization": "Bearer access.jwt"},
    )

    assert response.status_code == 200
    assert response.json() == {"status": "success", "data": {"message": "Logout successful"}}
    assert token_store.revoked == [("access-jti-1", 9999999999)]


def test_health_returns_ok():
    client = _make_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "success", "data": {"status": "ok"}}


def test_ready_returns_ready_when_dependencies_are_up(monkeypatch):
    client = _make_client()
    monkeypatch.setattr(main_module, "get_connection", lambda: FakeConnection())

    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json() == {"status": "success", "data": {"status": "ready"}}


def test_ready_returns_503_when_database_is_down(monkeypatch):
    client = _make_client()

    def _raise_db_error():
        raise RuntimeError("db down")

    monkeypatch.setattr(main_module, "get_connection", _raise_db_error)

    response = client.get("/ready")

    assert response.status_code == 503
    assert response.json() == {"status": "fail", "message": "Database unavailable"}
