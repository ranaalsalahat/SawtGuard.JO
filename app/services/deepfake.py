def predict_deepfake(filename: str, audio_data: bytes):
    return {
        "filename": filename,
        "prediction": "REAL",
        "confidence": 0.95,
        "mode": "mock"
    }
