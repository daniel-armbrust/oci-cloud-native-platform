#
# pizza/app/exceptions/handlers.py
#

from fastapi import Request
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.utils.jsend import fail


async def http_exception_handler(request: Request, exc: StarletteHTTPException):

    if exc.status_code == 404:
        return fail(
            {"message": "Resource not found"},
            status_code=404
        )

    return JSONResponse(
        status_code=exc.status_code,
        content={
            "status": "fail",
            "data": {
                "message": exc.detail
            }
        }
    )


async def global_exception_handler(request: Request, exc: Exception):

    return JSONResponse(
        status_code=500,
        content={
            "status": "error",
            "message": str(exc)
        }
    )