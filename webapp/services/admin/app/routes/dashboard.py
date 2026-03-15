from fastapi import APIRouter
from fastapi.responses import RedirectResponse

router = APIRouter()


@router.get("/admin")
def dashboard():
    return RedirectResponse("/admin/users", status_code=303)
