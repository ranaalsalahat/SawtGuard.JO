from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_security_headers():
    response = client.get("/health")

    assert response.status_code == 200

    assert response.headers["X-Content-Type-Options"] == "nosniff"
    assert response.headers["X-Frame-Options"] == "DENY"
    assert response.headers["Referrer-Policy"] == "no-referrer"
    assert response.headers["Cache-Control"] == "no-store"


def test_cors_allowed_origin():
    response = client.get(
        "/health",
        headers={
            "Origin": "http://localhost:3000"
        }
    )

    assert response.headers["Access-Control-Allow-Origin"] == (
        "http://localhost:3000"
    )


def test_cors_disallowed_origin():
    response = client.get(
        "/health",
        headers={
            "Origin": "https://untrusted.example"
        }
    )

    assert "Access-Control-Allow-Origin" not in response.headers



def test_large_content_length():
    response = client.post(
        "/api/deepfake",
        headers={
            "Content-Length": str(12 * 1024 * 1024)
        },
        content=b""
    )

    assert response.status_code == 413
    assert response.json()["detail"] == "Request too large"
