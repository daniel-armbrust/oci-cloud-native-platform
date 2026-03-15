#
# auth/app/metrics.py
#

from threading import Lock


class MetricsRegistry:
    def __init__(self):
        self._lock = Lock()
        self._values = {
            "auth_login_success_total": 0,
            "auth_login_fail_total": 0,
            "auth_refresh_success_total": 0,
            "auth_refresh_fail_total": 0,
            "auth_logout_total": 0,
        }

    def increment(self, key):
        with self._lock:
            self._values[key] = self._values.get(key, 0) + 1

    def render(self):
        with self._lock:
            lines = [
                "# HELP auth_login_success_total Successful login attempts",
                "# TYPE auth_login_success_total counter",
                f"auth_login_success_total {self._values['auth_login_success_total']}",
                "# HELP auth_login_fail_total Failed login attempts",
                "# TYPE auth_login_fail_total counter",
                f"auth_login_fail_total {self._values['auth_login_fail_total']}",
                "# HELP auth_refresh_success_total Successful refresh attempts",
                "# TYPE auth_refresh_success_total counter",
                f"auth_refresh_success_total {self._values['auth_refresh_success_total']}",
                "# HELP auth_refresh_fail_total Failed refresh attempts",
                "# TYPE auth_refresh_fail_total counter",
                f"auth_refresh_fail_total {self._values['auth_refresh_fail_total']}",
                "# HELP auth_logout_total Logout operations",
                "# TYPE auth_logout_total counter",
                f"auth_logout_total {self._values['auth_logout_total']}",
            ]

        return "\n".join(lines) + "\n"
