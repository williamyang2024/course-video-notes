# Failure Playbook

## Garbled Transcript
Symptoms:
- Text contains strings like `鎴`, `閫`, or many replacement characters.

Fix:
1. Stop note generation.
2. Re-run ASR from the original media.
3. Write output as UTF-8.
4. Validate by reading samples from the raw SRT.

## Chinese Path Failure
Symptoms:
- ASR or ffmpeg reports `Invalid argument`.
- The file path appears as `????`.

Fix:
1. Copy the media into an ASCII-only output directory.
2. Run the pipeline from that copied path.

## Download Failure
Symptoms:
- `yt-dlp` returns unsupported URL or HTTP 403.
- Platform login/cookie requirements block download.

Fix:
1. Try a direct media URL if available.
2. Try a platform-specific downloader if installed.
3. Ask the user for a local video file and continue from audio extraction.

## Notes Are Too Close To Transcript
Symptoms:
- `04_notes_chaptered.md` is basically a rewrapped transcript.

Fix:
1. Re-read the transcript by section.
2. Rewrite chapters into conclusions, steps, mistakes, and actions.
3. Keep direct quotes rare and only when useful.

## Long Video
Symptoms:
- ASR takes too long.

Fix:
1. Produce SRT first.
2. Generate notes in chapter batches.
3. Keep the user updated during long ASR runs.
