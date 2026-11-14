from app.config import MAX_AUDIO_SIZE_MB
from pathlib import Path
from fastapi import UploadFile, HTTPException

MAX_FILE_SIZE = MAX_AUDIO_SIZE_MB * 1024 * 1024  # 10 MB


async def validate_audio_file(file: UploadFile):
    filename = file.filename or ""
    extension = Path(filename).suffix.lower()

    if extension not in [".wav", ".mp3"]:
        raise HTTPException(
            status_code=400,
            detail="Only WAV and MP3 files are allowed"
        )

    data = await file.read(MAX_FILE_SIZE + 1)

    if len(data) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail="File too large. Maximum size is 10MB"
        )

    if not data:
        raise HTTPException(
            status_code=400,
            detail="Empty audio file"
        )

    is_wav = (
        len(data) >= 12
        and data.startswith(b"RIFF")
        and data[8:12] == b"WAVE"
    )

    is_mp3 = (
        data.startswith(b"ID3")
        or (
            len(data) >= 2
            and data[0] == 0xFF
            and (data[1] & 0xE0) == 0xE0
        )
    )

    if extension == ".wav" and not is_wav:
        raise HTTPException(
            status_code=400,
            detail="Invalid WAV file"
        )

    if extension == ".mp3" and not is_mp3:
        raise HTTPException(
            status_code=400,
            detail="Invalid MP3 file"
        )

    await file.seek(0)
    return True
