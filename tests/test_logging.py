import logging
from pathlib import Path

from fastapi.testclient import TestClient
from main import app
from app.logging_config import logger


def test_request_logging():
    with TestClient(app) as client:
        response = client.get("/health")

    assert response.status_code == 200

    for handler in logger.handlers:
        handler.flush()

    log_file = Path("logs/sawtguard.log")

    assert log_file.exists()

    logs = log_file.read_text()

    assert "method=GET" in logs
    assert "path=/health" in logs
    assert "status=200" in logs


def test_internal_error_handling():
    @app.get("/__test_internal_error", include_in_schema=False)
    def raise_test_error():
        raise RuntimeError("PRIVATE_TEST_ERROR_DO_NOT_EXPOSE")

    try:
        with TestClient(
            app,
            raise_server_exceptions=False
        ) as client:
            response = client.get("/__test_internal_error")

        assert response.status_code == 500

        data = response.json()

        assert data["detail"] == "Internal server error"
        assert "error_id" in data

        assert "PRIVATE_TEST_ERROR_DO_NOT_EXPOSE" not in response.text

    finally:
        app.router.routes = [
            route for route in app.router.routes
            if getattr(route, "path", None) != "/__test_internal_error"
        ]
