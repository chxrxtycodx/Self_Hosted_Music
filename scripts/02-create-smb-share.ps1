#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Shares the music folder over SMB for a single limited account.

.PARAMETER MusicFolder
    Full path to the music library folder.

.PARAMETER ShareName
    Name the share appears under on the network. Default: Music

.PARAMETER UserName
    Account allowed to access the share. Default: musicshare

.PARAMETER AllowWrite
    Grants modify access so files can be uploaded from other devices.
    Without it, access is read-only.

.EXAMPLE
    .\02-create-smb-share.ps1 -MusicFolder "C:\Users\<you>\Music\Library"
    .\02-create-smb-share.ps1 -MusicFolder "C:\Users\<you>\Music\Library" -AllowWrite
#>
param(
    [Parameter(Mandatory)][string]$MusicFolder,
    [string]$ShareName = "Music",
    [string]$UserName  = "musicshare",
    [switch]$AllowWrite
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $MusicFolder -PathType Container)) {
    throw "Folder not found: $MusicFolder`nCheck the path. If Music is synced by OneDrive, try C:\Users\<you>\OneDrive\Music\..."
}
if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
    throw "User '$UserName' does not exist. Run .\01-create-share-user.ps1 first."
}

$MusicFolder = (Resolve-Path -LiteralPath $MusicFolder).Path

# NTFS permissions: RX = read/execute, M = modify. (OI)(CI) applies to subfolders and files.
$ntfsRight = if ($AllowWrite) { "M" } else { "RX" }
icacls "$MusicFolder" /grant "${UserName}:(OI)(CI)$ntfsRight" /T /Q | Out-Null
if ($LASTEXITCODE -ne 0) { throw "icacls failed with exit code $LASTEXITCODE." }

$existing = Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue
if ($existing) {
    if ($existing.Path -ne $MusicFolder) {
        throw "A share named '$ShareName' already points to $($existing.Path). Choose another -ShareName."
    }
    $shareRight = if ($AllowWrite) { "Change" } else { "Read" }
    Grant-SmbShareAccess -Name $ShareName -AccountName $UserName -AccessRight $shareRight -Force | Out-Null
    Write-Host "Updated existing share '$ShareName' ($shareRight access for $UserName)." -ForegroundColor Green
} else {
    if ($AllowWrite) {
        New-SmbShare -Name $ShareName -Path $MusicFolder -ChangeAccess $UserName | Out-Null
    } else {
        New-SmbShare -Name $ShareName -Path $MusicFolder -ReadAccess $UserName | Out-Null
    }
    $mode = if ($AllowWrite) { "read/write" } else { "read-only" }
    Write-Host "Created share '$ShareName' -> $MusicFolder ($mode for $UserName)." -ForegroundColor Green
}

# Make sure the Tailscale adapter is treated as a private network so SMB is allowed on it.
$ts = Get-NetConnectionProfile -InterfaceAlias "Tailscale" -ErrorAction SilentlyContinue
if ($ts -and $ts.NetworkCategory -ne "Private") {
    Set-NetConnectionProfile -InterfaceAlias "Tailscale" -NetworkCategory Private
    Write-Host "Set the Tailscale network profile to Private."
}

Write-Host ""
Write-Host "Connect from another device:"
Write-Host "  VLC:        SMB, server <tailscale-ip>, user $UserName"
Write-Host "  iOS Files:  smb://<tailscale-ip>"
