#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Points Navidrome at your music folder and restarts the service.

.DESCRIPTION
    Useful when Navidrome was installed silently (e.g. plain `winget install`)
    and is scanning an empty default folder. Backs up the config before editing.

.PARAMETER MusicFolder
    Full path to the music library folder.

.PARAMETER ConfigPath
    Path to navidrome.ini. Default: C:\Program Files\Navidrome\navidrome.ini

.EXAMPLE
    .\04-configure-navidrome.ps1 -MusicFolder "C:\Users\<you>\Music\Library"
#>
param(
    [Parameter(Mandatory)][string]$MusicFolder,
    [string]$ConfigPath = "C:\Program Files\Navidrome\navidrome.ini"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $MusicFolder -PathType Container)) {
    throw "Folder not found: $MusicFolder"
}
$MusicFolder = (Resolve-Path -LiteralPath $MusicFolder).Path

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw @"
Config not found at $ConfigPath.
Reinstall with prompts and enter the folder there instead:
  winget uninstall Navidrome.Navidrome
  winget install Navidrome.Navidrome --interactive
"@
}

# Back up the existing config
$backup = "$ConfigPath.bak"
Copy-Item -LiteralPath $ConfigPath -Destination $backup -Force
Write-Host "Backed up config to $backup"

# Single-quoted TOML string so backslashes are taken literally
$newLine = "MusicFolder = '$MusicFolder'"
$content = Get-Content -LiteralPath $ConfigPath -Raw
if ($null -eq $content) { $content = "" }

if ($content -match '(?m)^\s*MusicFolder\s*=') {
    # MatchEvaluator avoids '$' and '\' in the path being treated as regex replacement tokens
    $content = [regex]::Replace($content, '(?m)^\s*MusicFolder\s*=.*$', { param($m) $newLine })
} else {
    $content = $content.TrimEnd() + [Environment]::NewLine + $newLine + [Environment]::NewLine
}

Set-Content -LiteralPath $ConfigPath -Value $content -Encoding UTF8
Write-Host "Set: $newLine" -ForegroundColor Green

$service = Get-Service | Where-Object { $_.Name -like "*navidrome*" -or $_.DisplayName -like "*navidrome*" } | Select-Object -First 1
if ($service) {
    Restart-Service -Name $service.Name
    Write-Host "Restarted service '$($service.Name)'. Open http://localhost:4533 and wait for the scan." -ForegroundColor Green
} else {
    Write-Warning "Navidrome service not found. Restart Navidrome manually."
}
