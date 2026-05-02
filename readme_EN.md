# Course Video Notes

Turn YouTube, TikTok, Douyin, Xiaohongshu/RedNote, X/Twitter, direct MP4 links, or local course videos into reusable learning assets.

This project started as a Codex skill. It connects video download, audio extraction, speech transcription, transcript cleanup, chaptered notes, and action checklists into one repeatable workflow.

## Features

- Accepts remote video links or local video files.
- Downloads accessible media sources automatically.
- Extracts 16 kHz mono audio with `ffmpeg`.
- Generates timestamped SRT transcripts with `faster-whisper`.
- Produces cleaned transcripts, chaptered notes, and action checklists.
- Includes failure-handling guidance to prevent garbled transcripts from polluting downstream notes.

## Supported Sources

- YouTube
- TikTok
- X/Twitter
- Douyin
- Xiaohongshu / RedNote
- Direct MP4 links
- Local video files

Platform APIs change frequently. If automated download fails, download the video manually and continue the pipeline with the local file path.

## Project Structure

```text
course-video-notes/
├── SKILL.md
├── references/
│   ├── failure-playbook.md
│   ├── platform-routing.md
│   └── workflow.md
└── scripts/
    ├── download_media.ps1
    └── run_pipeline.ps1
```

## Requirements

- Windows PowerShell
- Git
- Python 3.11+
- `ffmpeg`
- `yt-dlp`
- `faster-whisper`

Install Python dependencies:

```powershell
py -m pip install -U yt-dlp faster-whisper
```

## Usage

Process an online video:

```powershell
& '.\scripts\run_pipeline.ps1' `
  -Source "https://www.youtube.com/watch?v=VIDEO_ID" `
  -OutDir ".\output\my-course" `
  -Slug "my-course"
```

Process a local video:

```powershell
& '.\scripts\run_pipeline.ps1' `
  -VideoPath "D:\Videos\course.mp4" `
  -OutDir ".\output\my-course" `
  -Slug "my-course"
```

## Outputs

The pipeline creates:

- `01_source_meta.md`
- `02_transcript_raw.srt`
- `03_transcript_clean.md`
- `04_notes_chaptered.md`
- `05_action_checklist.md`

`04_notes_chaptered.md` and `05_action_checklist.md` are structured placeholders for an agent to refine after reading the SRT and cleaned transcript.

## Principles

- Do not generate notes from garbled transcripts.
- Do not rewrap transcripts and call them notes.
- Keep the raw SRT for review.
- Notes should include conclusions, steps, mistakes, and actions.

## License

MIT
