from app.security.error_handling import (
    log_requests,
    handle_unexpected_error
)
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.audio import router as audio_router
from app.security.headers import add_security_headers
from app.security.request_size import limit_request_size


app = FastAPI(
    title="SawtGuard JO API",
    description="Backend API for Deepfake and Sound Detection",
    version="1.0.0"
)


# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000"
    ],
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)


# Security Headers
app.middleware("http")(add_security_headers)


# Request Size Protection
app.middleware("http")(limit_request_size)


# Audio API Routes
app.middleware("http")(log_requests)

app.add_exception_handler(Exception, handle_unexpected_error)

app.include_router(audio_router)


@app.get("/")
def home():
    return {
        "project": "SawtGuard JO",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }
