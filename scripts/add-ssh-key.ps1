#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Authorizes a device's SSH public key (e.g. from the iOS Shortcuts app).

.DESCRIPTION
    For accounts in the Administrators group, Windows OpenSSH reads keys from
    C:\ProgramData\ssh\administrators_authorized_keys, not the user's own
    .ssh folder. This script writes to the correct file for the target account
    and sets the strict permissions sshd requires.

.PARAMETER PublicKey
    The full public key line, e.g. "ssh-ed25519 AAAA... iphone".

.PARAMETER UserName
    Account the key logs in as. Default: the current user.

.EXAMPLE
    .\add-ssh-key.ps1 -PublicKey "ssh-ed25519 AAAAC3Nza... iphone"
#>
param(
    [Parameter(Mandatory)][string]$PublicKey,
    [string]$UserName = $env:USERNAME
)

$ErrorActionPreference = "Stop"

$PublicKey = $PublicKey.Trim()
if ($PublicKey -notmatch '^(ssh-(ed25519|rsa)|ecdsa-sha2-nistp\d+)\s+\S+') {
    throw "That doesn't look like an SSH public key. It should start with ssh-ed25519, ssh-rsa, or ecdsa-sha2-..."
}

$isAdmin = (Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "*\$UserName" }) -ne $null

if ($isAdmin) {
    $keyFile = "C:\ProgramData\ssh\administrators_authorized_keys"
    if (-not (Test-Path $keyFile)) { New-Item -ItemType File -Path $keyFile -Force | Out-Null }
    if (-not (Select-String -LiteralPath $keyFile -SimpleMatch $PublicKey -Quiet)) {
        Add-Content -LiteralPath $keyFile -Value $PublicKey
    }
    icacls $keyFile /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F" | Out-Null
} else {
    $sshDir  = "C:\Users\$UserName\.ssh"
    $keyFile = Join-Path $sshDir "authorized_keys"
    if (-not (Test-Path $sshDir)) { New-Item -ItemType Directory -Path $sshDir -Force | Out-Null }
    if (-not (Test-Path $keyFile)) { New-Item -ItemType File -Path $keyFile -Force | Out-Null }
    if (-not (Select-String -LiteralPath $keyFile -SimpleMatch $PublicKey -Quiet)) {
        Add-Content -LiteralPath $keyFile -Value $PublicKey
    }
    icacls $keyFile /inheritance:r /grant "${UserName}:F" /grant "SYSTEM:F" | Out-Null
}

Write-Host "Authorized key for '$UserName' in $keyFile" -ForegroundColor Green
