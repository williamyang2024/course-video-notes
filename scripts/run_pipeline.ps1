param(
  [string]$Source,
  [string]$VideoPath,
  [Parameter(Mandatory=$true)][string]$OutDir,
  [string]$Slug = "course-video"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$skillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$downloadScript = Join-Path $skillRoot "scripts\download_media.ps1"

if (-not $VideoPath) {
  if (-not $Source) {
    throw "Provide either -Source URL/path or -VideoPath local file."
  }
  $VideoPath = & $downloadScript -Source $Source -OutDir $OutDir -FileName $Slug
  $VideoPath = ($VideoPath | Select-Object -Last 1).Trim()
}

if (-not (Test-Path -LiteralPath $VideoPath)) {
  throw "Video file not found: $VideoPath"
}

$meta = Get-Item -LiteralPath $VideoPath
@"
# Source Meta

- source: $Source
- video: $($meta.FullName)
- size_bytes: $($meta.Length)
- modified: $($meta.LastWriteTime)
- pipeline: course-video-notes
"@ | Set-Content -LiteralPath (Join-Path $OutDir "01_source_meta.md") -Encoding utf8

$wav = Join-Path $OutDir "audio_16k_mono.wav"
ffmpeg -y -i "$VideoPath" -vn -ac 1 -ar 16000 -c:a pcm_s16le "$wav" | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "ffmpeg failed to extract audio."
}

$py = @'
from faster_whisper import WhisperModel
from pathlib import Path
import sys

wav = Path(sys.argv[1])
out = Path(sys.argv[2])
model_name = sys.argv[3] if len(sys.argv) > 3 else "small"

model = WhisperModel(model_name, device="cpu", compute_type="int8")
segments_iter, info = model.transcribe(str(wav), language="zh", vad_filter=True, beam_size=5)
segments = list(segments_iter)

def ts(x):
    h = int(x // 3600); x -= h * 3600
    m = int(x // 60); x -= m * 60
    s = int(x); ms = int(round((x - s) * 1000))
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

srt = out / "02_transcript_raw.srt"
with srt.open("w", encoding="utf-8") as f:
    i = 1
    for seg in segments:
        text = (seg.text or "").strip()
        if not text:
            continue
        f.write(f"{i}\n{ts(seg.start)} --> {ts(seg.end)}\n{text}\n\n")
        i += 1

clean = out / "03_transcript_clean.md"
with clean.open("w", encoding="utf-8") as f:
    f.write("# Clean Transcript\n\n")
    f.write("> Generated from 02_transcript_raw.srt. Review important terms against the original video.\n\n")
    for seg in segments:
        text = (seg.text or "").strip()
        if not text:
            continue
        f.write(f"- [{ts(seg.start)} - {ts(seg.end)}] {text}\n")

sample = "".join((seg.text or "") for seg in segments[:20])
bad_markers = [chr(0x93B4), chr(0x95AB), chr(0xFFFD)]
if any(marker in sample for marker in bad_markers):
    raise SystemExit("Transcript appears garbled. Re-run ASR from source media.")
'@

$tmp = Join-Path $OutDir "_run_asr.py"
$py | Set-Content -LiteralPath $tmp -Encoding utf8
py $tmp $wav $OutDir "small"
if ($LASTEXITCODE -ne 0) {
  throw "ASR failed."
}

@"
# Chaptered Notes

This placeholder must be replaced by the agent after reading `02_transcript_raw.srt`.

Required structure for each chapter:
- Core conclusion
- Key points
- Steps
- Common mistakes
- Actions
"@ | Set-Content -LiteralPath (Join-Path $OutDir "04_notes_chaptered.md") -Encoding utf8

@"
# Action Checklist

This placeholder must be replaced by the agent after reading `04_notes_chaptered.md`.
"@ | Set-Content -LiteralPath (Join-Path $OutDir "05_action_checklist.md") -Encoding utf8

Write-Output "Pipeline done: $OutDir"
