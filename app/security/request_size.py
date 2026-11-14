from fastapi import Request
from fastapi.responses import JSONResponse

MAX_REQUEST_SIZE = 11 * 1024 * 1024


async def limit_request_size(request: Request, call_next):
    if request.url.path in ["/api/deepfake", "/api/sound"]:
        content_length = request.headers.get("content-length")

        if content_length is not None:
            try:
                size = int(content_length)
            except ValueError:
                return JSONResponse(
                    status_code=400,
                    content={"detail": "Invalid Content-Length"}
                )

            if size < 0:
                return JSONResponse(
                    status_code=400,
                    content={"detail": "Invalid Content-Length"}
                )

            if size > MAX_REQUEST_SIZE:
                return JSONResponse(
                    status_code=413,
                    content={"detail": "Request too large"}
                )

    return await call_next(request)
