def predict_sound(filename: str, audio_data: bytes):
    return {
        "filename": filename,
        "prediction": "CAR_HORN",
        "confidence": 0.91,
        "mode": "mock"
    }
