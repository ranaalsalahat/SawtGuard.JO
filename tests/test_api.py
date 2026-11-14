import io
import wave

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def create_wav():
    buffer = io.BytesIO()

    with wave.open(buffer, "wb") as audio:
        audio.setnchannels(1)
        audio.setsampwidth(2)
        audio.setframerate(8000)
        audio.writeframes(b"\x00\x00" * 8000)

    return buffer.getvalue()


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_valid_audio():
    response = client.post(
        "/api/deepfake",
        files={
            "file": ("test.wav", create_wav(), "audio/wav")
        }
    )

    assert response.status_code == 200
    assert response.json()["mode"] == "mock"


def test_invalid_extension():
    response = client.post(
        "/api/deepfake",
        files={
            "file": ("test.txt", b"not audio", "text/plain")
        }
    )

    assert response.status_code == 400


def test_fake_wav():
    response = client.post(
        "/api/deepfake",
        files={
            "file": ("fake.wav", b"not audio", "audio/wav")
        }
    )

    assert response.status_code == 400


def test_large_audio():
    large_wav = create_wav() + b"\x00" * (11 * 1024 * 1024)

    response = client.post(
        "/api/deepfake",
        files={
            "file": ("large.wav", large_wav, "audio/wav")
        }
    )

    assert response.status_code == 413

