#
# admin/app/main.py
#

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pathlib import Path

from app.routes import login, dashboard, users

BASE_DIR = Path(__file__).resolve().parent

app = FastAPI()

app.mount("/static", StaticFiles(directory=BASE_DIR / "static"), name="static")

app.include_router(login.router)
app.include_router(dashboard.router)
app.include_router(users.router)