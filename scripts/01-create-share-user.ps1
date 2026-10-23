#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Creates a limited local account used only for SMB access to the music folder.

.DESCRIPTION
    Windows Hello / passkey sign-in can prevent a Microsoft account password from
    working for network (SMB) logins. A dedicated local account with its own
    password avoids that and limits access to the music folder only.

    The password is prompted securely and never stored in this script.

.PARAMETER UserName
    Name of the local account. Default: musicshare

.PARAMETER ShowOnLoginScreen
    By default the account is hidden from the Windows sign-in screen.
    Use this switch to leave it visible.

.EXAMPLE
    .\01-create-share-user.ps1
    .\01-create-share-user.ps1 -UserName mymusic
#>
param(
    [string]$UserName = "musicshare",
    [switch]$ShowOnLoginScreen
)

$ErrorActionPreference = "Stop"

if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Write-Host "User '$UserName' already exists. Skipping creation." -ForegroundColor Yellow
    Write-Host "To reset its password: Set-LocalUser -Name $UserName -Password (Read-Host -AsSecureString)"
    return
}

$password = Read-Host -AsSecureString "Enter a strong password for '$UserName'"
$confirm  = Read-Host -AsSecureString "Confirm password"

$p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm))
if ($p1 -ne $p2) { throw "Passwords do not match." }
if ($p1.Length -lt 12) { Write-Warning "Password is shorter than 12 characters. Consider a longer one." }
$p1 = $null; $p2 = $null

New-LocalUser -Name $UserName `
              -Password $password `
              -Description "Limited account for music folder SMB access" `
              -PasswordNeverExpires `
              -UserMayNotChangePassword | Out-Null

Write-Host "Created local user '$UserName' (standard user, not an administrator)." -ForegroundColor Green

if (-not $ShowOnLoginScreen) {
    $key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    New-ItemProperty -Path $key -Name $UserName -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "Hidden '$UserName' from the sign-in screen."
}

Write-Host "Next: .\02-create-smb-share.ps1 -MusicFolder `"<music-folder>`""
