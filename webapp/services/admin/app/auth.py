#
# admin/app/auth.py
#

import bcrypt

from app.db import get_connection

def authenticate(email, password):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM users WHERE email=%s AND role='admin' LIMIT 1",
        (email,)
    )

    user = cursor.fetchone()

    if not user:
        return None

    if bcrypt.checkpw(password.encode(), user["password_hash"].encode()):
        return user

    return None