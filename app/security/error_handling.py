import time
import uuid

from fastapi import Request
from fastapi.responses import JSONResponse

from app.logging_config import logger


async def log_requests(request: Request, call_next):
    start_time = time.monotonic()

    response = await call_next(request)

    duration = round(
        (time.monotonic() - start_time) * 1000, 2
    )

    logger.info(
        "method=%s path=%s status=%s duration_ms=%s",
        request.method,
        request.url.path,
        response.status_code,
        duration
    )

    return response


async def handle_unexpected_error(
    request: Request,
    exc: Exception
):
    error_id = str(uuid.uuid4())

    logger.error(
        "error_id=%s method=%s path=%s type=%s",
        error_id,
        request.method,
        request.url.path,
        type(exc).__name__
    )

    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "error_id": error_id
        }
    )
