#
# pizza/app/api/health.py
#

from fastapi import APIRouter

router = APIRouter()

@router.get("/health")
def health():
    return {"status": "ok"}

@router.get("/ready")
def readiness():
    return {"status": "ready"}