import io
import wave

from fastapi.testclient import TestClient

from main import app
from app.security.rate_limit import request_history

client = TestClient(app)


def create_wav():
    buffer = io.BytesIO()

    with wave.open(buffer, "wb") as audio:
        audio.setnchannels(1)
        audio.setsampwidth(2)
        audio.setframerate(8000)
        audio.writeframes(b"\x00\x00" * 8000)

    return buffer.getvalue()


def test_rate_limiting():

    # Clear previous requests
    request_history.clear()

    audio = create_wav()

    # Send 10 requests
    for i in range(10):
        response = client.post(
            "/api/deepfake",
            files={
                "file": ("test.wav", audio, "audio/wav")
            }
        )

        assert response.status_code == 200

    # Send request number 11
    response = client.post(
        "/api/deepfake",
        files={
            "file": ("test.wav", audio, "audio/wav")
        }
    )

    assert response.status_code == 429

    assert response.json()["detail"] == (
        "Too many requests. Please try again later."
    )

    request_history.clear()
