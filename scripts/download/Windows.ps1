$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-StrictMode -Version Latest
Write-Host ::group::Downloading Rclone $env:version for Windows
$base = "$env:GITHUB_SERVER_URL/benjithatfoxguy/bclone/releases/download/$env:version"

# Releases from v1.76.0 ship bclone-*.zip holding bclone.exe; older ones ship
# rclone-*.zip holding rclone.exe.
$arch = if ($env:RUNNER_ARCH -eq 'ARM64') { 'arm64' } else { 'amd64' }
$dir = $null
foreach ($name in 'bclone', 'rclone') {
  $candidate = "$name-$env:version-windows-$arch"
  try {
    Invoke-WebRequest "$base/$candidate.zip" -OutFile "$candidate.zip"
    $dir = $candidate
    break
  }
  catch {
    Write-Host "No $candidate.zip"
  }
}
if (-not $dir) {
  Write-Host "::error::No bclone or rclone archive found for $env:version windows-$arch"
  exit 1
}

Expand-Archive "$dir.zip" Rclone
Move-Item Rclone\$dir\* Rclone
Remove-Item "$dir.zip", Rclone\$dir

# Provide both command names whichever one the archive had
if (-not (Test-Path Rclone\rclone.exe)) { Copy-Item Rclone\bclone.exe Rclone\rclone.exe }
if (-not (Test-Path Rclone\bclone.exe)) { Copy-Item Rclone\rclone.exe Rclone\bclone.exe }
Write-Host ::endgroup::
