#
# pizza/utils/jsend.py
#

from fastapi.responses import JSONResponse

def success(data, status_code=200):
    return JSONResponse(
        status_code=status_code,
        content={
            "status": "success",
            "data": data
        }
    )

def fail(data, status_code=400):
    return JSONResponse(
        status_code=status_code,
        content={
            "status": "fail",
            "data": data
        }
    )

def error(message, status_code=500):
    return JSONResponse(
        status_code=status_code,
        content={
            "status": "error",
            "message": message
        }
    )