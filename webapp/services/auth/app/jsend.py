#
# auth/app/jsend.py
#

from fastapi.responses import JSONResponse


def success(data=None, status_code=200):
    payload = {"status": "success"}

    if data is not None:
        payload["data"] = data

    return JSONResponse(status_code=status_code, content=payload)


def fail(message, status_code=400):
    return JSONResponse(
        status_code=status_code,
        content={"status": "fail", "message": message},
    )


def error(message="Internal server error", status_code=500):
    return JSONResponse(
        status_code=status_code,
        content={"status": "error", "message": message},
    )
