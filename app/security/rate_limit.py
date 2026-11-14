from app.config import RATE_LIMIT_REQUESTS, RATE_LIMIT_WINDOW
import time
from collections import defaultdict, deque
from threading import Lock

from fastapi import HTTPException, Request

MAX_REQUESTS = RATE_LIMIT_REQUESTS
WINDOW_SECONDS = RATE_LIMIT_WINDOW

request_history = defaultdict(deque)
rate_limit_lock = Lock()


def check_rate_limit(request: Request):
    client_ip = request.client.host if request.client else "unknown"

    current_time = time.monotonic()

    with rate_limit_lock:
        timestamps = request_history[client_ip]

        while timestamps and current_time - timestamps[0] >= WINDOW_SECONDS:
            timestamps.popleft()

        if len(timestamps) >= MAX_REQUESTS:
            raise HTTPException(
                status_code=429,
                detail="Too many requests. Please try again later."
            )

        timestamps.append(current_time)
