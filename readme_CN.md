# Course Video Notes

把 YouTube、TikTok、抖音、小红书/RedNote、X/Twitter 或本地课程视频处理成可学习的知识资产。

这个项目最初是一个 Codex skill，用来把视频下载、音频提取、语音转写、逐字稿清洗、章节笔记和行动清单串成一条稳定流程。

## 功能

- 支持在线链接或本地视频文件。
- 自动下载可访问的视频源。
- 使用 `ffmpeg` 提取 16k 单声道音频。
- 使用 `faster-whisper` 生成带时间戳的 SRT。
- 输出清洗逐字稿、章节笔记和行动清单。
- 内置失败处理指南，避免乱码转写继续污染笔记。

## 支持平台

- YouTube
- TikTok
- X/Twitter
- 抖音
- 小红书 / RedNote
- 直接 MP4 链接
- 本地视频文件

平台接口变化很快，下载失败时可以先手动下载视频，再把本地路径交给流水线继续处理。

## 目录结构

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

## 环境要求

- Windows PowerShell
- Git
- Python 3.11+
- `ffmpeg`
- `yt-dlp`
- `faster-whisper`

安装 Python 依赖：

```powershell
py -m pip install -U yt-dlp faster-whisper
```

## 使用方法

处理在线视频链接：

```powershell
& '.\scripts\run_pipeline.ps1' `
  -Source "https://www.youtube.com/watch?v=VIDEO_ID" `
  -OutDir ".\output\my-course" `
  -Slug "my-course"
```

处理本地视频：

```powershell
& '.\scripts\run_pipeline.ps1' `
  -VideoPath "D:\Videos\course.mp4" `
  -OutDir ".\output\my-course" `
  -Slug "my-course"
```

## 输出文件

流水线会生成：

- `01_source_meta.md`
- `02_transcript_raw.srt`
- `03_transcript_clean.md`
- `04_notes_chaptered.md`
- `05_action_checklist.md`

其中 `04_notes_chaptered.md` 和 `05_action_checklist.md` 是给 agent 后续整理的结构化占位文件。实际使用时，应读取 SRT 和清洗稿后，把它们改写成真正的章节笔记和执行清单。

## 重要原则

- 不要从乱码逐字稿生成笔记。
- 不要把逐字稿简单分章后冒充笔记。
- 原始 SRT 要保留，便于复核。
- 笔记要输出结论、步骤、误区和行动。

## License

MIT
