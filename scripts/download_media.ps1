param(
  [Parameter(Mandatory=$true)][string]$Source,
  [Parameter(Mandatory=$true)][string]$OutDir,
  [string]$FileName = "source"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Resolve-YtDlp {
  $cmd = Get-Command yt-dlp -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }

  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts\yt-dlp.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\yt-dlp.exe",
    "$env:APPDATA\Python\Python312\Scripts\yt-dlp.exe",
    "$env:APPDATA\Python\Python311\Scripts\yt-dlp.exe"
  )
  foreach ($path in $candidates) {
    if (Test-Path -LiteralPath $path) { return $path }
  }
  return $null
}

function Get-Platform {
  param([string]$Url)
  if ($Url -match "x\.com|twitter\.com") { return "x" }
  if ($Url -match "youtube\.com|youtu\.be") { return "youtube" }
  if ($Url -match "tiktok\.com") { return "tiktok" }
  if ($Url -match "douyin\.com|iesdouyin\.com") { return "douyin" }
  if ($Url -match "xiaohongshu\.com|xhslink\.com|rednote") { return "xhs" }
  if ($Url -match "\.mp4(\?|$)|\.m3u8(\?|$)") { return "direct" }
  return "generic"
}

if (Test-Path -LiteralPath $Source) {
  $srcItem = Get-Item -LiteralPath $Source
  $target = Join-Path $OutDir ("$FileName" + $srcItem.Extension)
  Copy-Item -LiteralPath $srcItem.FullName -Destination $target -Force
  Write-Output $target
  exit 0
}

$platform = Get-Platform $Source

if ($platform -eq "x") {
  if ($Source -match "status/(\d+)") {
    $id = $Matches[1]
    $metaUrl = "https://cdn.syndication.twimg.com/tweet-result?id=$id&token=0"
    $json = Invoke-WebRequest -Uri $metaUrl -UseBasicParsing -TimeoutSec 30 | Select-Object -ExpandProperty Content
    $tweet = $json | ConvertFrom-Json
    $variants = @($tweet.video.variants | Where-Object { $_.type -eq "video/mp4" -and $_.src })
    if (-not $variants -or $variants.Count -eq 0) {
      throw "No MP4 variants found for X/Twitter status."
    }
    $best = $variants | Sort-Object { if ($_.bitrate) { [int]$_.bitrate } else { 0 } } -Descending | Select-Object -First 1
    $target = Join-Path $OutDir "$FileName.mp4"
    Invoke-WebRequest -Uri $best.src -OutFile $target -UseBasicParsing -TimeoutSec 180
    Write-Output $target
    exit 0
  }
}

if ($platform -eq "direct") {
  $target = Join-Path $OutDir "$FileName.mp4"
  Invoke-WebRequest -Uri $Source -OutFile $target -UseBasicParsing -TimeoutSec 180
  Write-Output $target
  exit 0
}

$ytDlp = Resolve-YtDlp
if (-not $ytDlp) {
  throw "yt-dlp is not installed or not found. Install with: py -m pip install -U yt-dlp"
}

$template = Join-Path $OutDir "$FileName.%(ext)s"
& $ytDlp -f "bv*+ba/b" --merge-output-format mp4 -o $template $Source
if ($LASTEXITCODE -ne 0) {
  throw "yt-dlp failed for platform '$platform'. Try a dedicated downloader or provide a local file."
}

$downloaded = Get-ChildItem -LiteralPath $OutDir -File |
  Where-Object { $_.BaseName -eq $FileName } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $downloaded) {
  throw "Download completed but output file was not found."
}

Write-Output $downloaded.FullName
