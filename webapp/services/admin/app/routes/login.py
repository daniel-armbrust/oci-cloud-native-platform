#
# admin/app/routes/login.py
#

from fastapi import APIRouter, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse

from app.core.templates import templates
from ..auth import authenticate

router = APIRouter()

@router.get("/")
def root():
    return RedirectResponse("/login", status_code=303)

@router.get("/login", response_class=HTMLResponse)
def login_page(request: Request):

    return templates.TemplateResponse(
        "login.html",
        {"request": request}
    )

@router.post("/login")
def login(request: Request, email: str = Form(...), password: str = Form(...)):
    user = authenticate(email, password)

    if not user:
        return RedirectResponse("/login", status_code=303)

    response = RedirectResponse("/admin", status_code=303)

    response.set_cookie(
        key="admin",
        value=user["id"],
        httponly=True
    )

    return response
