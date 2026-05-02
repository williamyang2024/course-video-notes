# Course Video Notes Workflow

## A. Input
Accept one of:
- Remote URL: YouTube, TikTok, Douyin, Xiaohongshu/RedNote, X/Twitter, direct MP4.
- Local video path.

Create one output directory per source:
- `output/<slug>/`

## B. Download
Use `scripts/download_media.ps1`.

Expected result:
- A local video file in the output directory.

## C. Audio Normalization
Use ffmpeg:
- WAV
- 16 kHz
- mono

Expected result:
- `audio_16k_mono.wav`

## D. ASR
Use faster-whisper or FunASR.

Expected result:
- `02_transcript_raw.srt`
- `03_transcript_clean.md`

## E. Quality Gate
Before writing notes:
1. Read the first, middle, and last parts of `02_transcript_raw.srt`.
2. Confirm the transcript is readable.
3. Check that it is not garbled.
4. If it fails, re-run ASR from the original media.

## F. Notes
Read the transcript and write `04_notes_chaptered.md`.

Each chapter should include:
- Core conclusion
- Key points
- Steps
- Common mistakes
- Actions

## G. Checklist
Write `05_action_checklist.md`.

The checklist should turn the course into:
- Daily actions
- Review questions
- Practice tasks
- Follow-up resources if useful

## H. Final Response
Report:
- Source media path
- Raw transcript path
- Clean transcript path
- Chaptered notes path
- Action checklist path
- Any quality risks
