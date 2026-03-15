"""
OCI Pizza Platform

Script: seed-users.py
"""

import os
import time
import uuid
import random
import string
import bcrypt
import mysql.connector
from faker import Faker

fake = Faker("pt_BR")

host = os.getenv("MYSQL_HOST")
port = os.getenv("MYSQL_PORT", 3306)
user = os.getenv("MYSQL_USER")
password = os.getenv("MYSQL_PASSWORD")
database = os.getenv("MYSQL_DATABASE")

admin_email = os.getenv("ADMIN_EMAIL")
admin_password = os.getenv("ADMIN_PASSWORD")

if not admin_email or not admin_password:
    raise RuntimeError("ADMIN_EMAIL or ADMIN_PASSWORD not defined")

for i in range(10):
    try:
        conn = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=database
        )
        break
    except:
        print("Waiting for mysql...")
        time.sleep(3)

cursor = conn.cursor()

# -----------------------------------------
# Criar admin ou atualizar senha se já existir
# -----------------------------------------
cursor.execute("SELECT id FROM users WHERE email = %s", (admin_email,))
admin = cursor.fetchone()
admin_hash = bcrypt.hashpw(admin_password.encode(), bcrypt.gensalt()).decode()

if not admin:
    cursor.execute("""
        INSERT INTO users (
            id,
            name,
            email,
            password_hash,
            role,
            whatsapp,
            active
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (
        str(uuid.uuid4()),
        "Administrator",
        admin_email,
        admin_hash,
        "admin",
        "+5511999999999",
        True
    ))

    print("\nAdmin created")
    print("Email:", admin_email)
    print("Password:", admin_password)
    print("------")
else:
    cursor.execute("""
        UPDATE users
        SET password_hash = %s
        WHERE id = %s
    """, (
        admin_hash,
        admin[0]
    ))

    print("\nAdmin password updated")
    print("Email:", admin_email)
    print("Password:", admin_password)
    print("------")

# -----------------------------------------
# Criar usuários fake
# -----------------------------------------

def random_password(length=10):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

for i in range(5):
    password = random_password()

    password_hash = bcrypt.hashpw(
        password.encode(),
        bcrypt.gensalt()
    ).decode()

    user_id = str(uuid.uuid4())
    name = fake.name()
    email = fake.email()
    whatsapp = "+55" + str(random.randint(11900000000,11999999999))

    cursor.execute("""
        INSERT INTO users (
            id,
            name,
            email,
            password_hash,
            role,
            whatsapp,
            active
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (
        user_id,
        name,
        email,
        password_hash,
        "user",
        whatsapp,
        False
    ))

    print(f"\nUser {i+1}:")
    print(f"Email: {email}")
    print(f"Password: {password}")
    print("------")

conn.commit()
cursor.close()
conn.close()
