# Platform Routing

## Goal
Resolve a user-provided video source into a local MP4 file before transcription.

## Supported Inputs
- Local file path: start from the file directly.
- Direct media URL: download with `Invoke-WebRequest`.
- X/Twitter status URL: call public tweet metadata and choose the highest bitrate MP4.
- YouTube/TikTok URL: use `yt-dlp`.
- Douyin URL: try `yt-dlp`; use a dedicated Douyin downloader when available.
- Xiaohongshu/RedNote URL: prefer a dedicated XHS downloader when available.

## Tool Preference
1. `scripts/download_media.ps1`
2. Platform-specific tool if already installed.
3. Ask the user for a local video file when a platform blocks automated download.

## Notes
- Platform support changes frequently. Keep the downloader loosely coupled from the ASR and note pipeline.
- Do not treat download failure as transcription failure. If the user can provide the local file, continue from that point.
