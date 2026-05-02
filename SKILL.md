---
name: course-video-notes
description: Use this skill when the user wants to download online course/social videos from YouTube, TikTok, Douyin, Xiaohongshu/RedNote, X/Twitter, direct video URLs, or local files, then extract audio, transcribe speech, create cleaned transcripts, chaptered knowledge notes, and actionable summaries.
---

# Course Video Notes

## When To Use
- The user wants to turn a video, course, livestream replay, or social video into learning notes.
- Inputs may be YouTube, TikTok, Douyin, Xiaohongshu/RedNote, X/Twitter, a direct media URL, or a local video path.
- The expected result is a reusable learning package, not just a raw transcript.

## Output Contract
Always produce these files in the output directory:
1. `01_source_meta.md` - source URL/path, resolved platform, media file, processing log.
2. `02_transcript_raw.srt` - timestamped ASR transcript.
3. `03_transcript_clean.md` - readable transcript with light cleanup.
4. `04_notes_chaptered.md` - chaptered knowledge notes, not verbatim text.
5. `05_action_checklist.md` - execution checklist and review plan.

## Standard Workflow
1. Resolve source and identify platform.
2. Download remote media if needed.
3. Extract audio to WAV 16k mono.
4. Run ASR to SRT with `faster-whisper` or FunASR.
5. Validate transcript readability before note generation.
6. Create cleaned transcript.
7. Create chaptered notes.
8. Create action checklist.

## Platform Routing
- YouTube/TikTok: prefer `yt-dlp`.
- X/Twitter: prefer tweet metadata API and highest bitrate MP4; fall back to `yt-dlp`.
- Douyin: try `yt-dlp`; if it fails, use a dedicated Douyin downloader if installed.
- Xiaohongshu/RedNote: use a dedicated XHS downloader if installed; otherwise ask for a local export or browser-copied share URL.
- Local file: skip download and start at audio extraction.

## Critical Rules
- Never generate notes from garbled or mojibake transcripts.
- If transcript text is garbled, re-run ASR from the original media.
- Keep raw SRT even if later summaries are refined.
- Distinguish transcript from notes:
  - transcript: close to the source.
  - notes: summarized, structured, actionable.
- For Chinese users, write final notes in Chinese. Keep scripts mostly ASCII to avoid encoding failures.

## References
- Workflow: `references/workflow.md`
- Failure handling: `references/failure-playbook.md`
- Platform routing: `references/platform-routing.md`
- Downloader: `scripts/download_media.ps1`
- Pipeline: `scripts/run_pipeline.ps1`
