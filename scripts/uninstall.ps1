#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Removes the SMB share, the sharing account, and firewall rules created by
    these scripts. Your music files are not touched.

.PARAMETER ShareName
    SMB share to remove. Default: Music

.PARAMETER UserName
    Sharing account to delete. Default: musicshare

.PARAMETER RemoveSsh
    Also stop and disable the OpenSSH server.

.EXAMPLE
    .\uninstall.ps1
    .\uninstall.ps1 -ShareName Music -RemoveSsh
#>
param(
    [string]$ShareName = "Music",
    [string]$UserName  = "musicshare",
    [switch]$RemoveSsh
)

if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
    Remove-SmbShare -Name $ShareName -Force
    Write-Host "Removed share '$ShareName'."
}

if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Remove-LocalUser -Name $UserName
    Write-Host "Deleted user '$UserName'."
}
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" `
                    -Name $UserName -ErrorAction SilentlyContinue

if (Get-NetFirewallRule -DisplayName "Navidrome" -ErrorAction SilentlyContinue) {
    Remove-NetFirewallRule -DisplayName "Navidrome"
    Write-Host "Removed firewall rule 'Navidrome'."
}

if ($RemoveSsh) {
    Stop-Service sshd -ErrorAction SilentlyContinue
    Set-Service sshd -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "Stopped and disabled OpenSSH Server."
}

Write-Host "Done. To remove Navidrome itself: winget uninstall Navidrome.Navidrome" -ForegroundColor Green
