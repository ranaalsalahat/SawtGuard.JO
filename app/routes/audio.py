from fastapi import APIRouter, UploadFile, File, Request

from app.security.validation import validate_audio_file
from app.security.rate_limit import check_rate_limit
from app.services.deepfake import predict_deepfake
from app.services.sound import predict_sound

router = APIRouter()


@router.post("/api/deepfake")
async def detect_deepfake(
    request: Request,
    file: UploadFile = File(...)
):
    check_rate_limit(request)
    await validate_audio_file(file)

    audio_data = await file.read()

    return predict_deepfake(file.filename, audio_data)


@router.post("/api/sound")
async def detect_sound(
    request: Request,
    file: UploadFile = File(...)
):
    check_rate_limit(request)
    await validate_audio_file(file)

    audio_data = await file.read()

    return predict_sound(file.filename, audio_data)
