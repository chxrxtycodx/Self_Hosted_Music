#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Optional: enables the built-in OpenSSH server so iOS Shortcuts can run
    commands on this PC over Tailscale.

.DESCRIPTION
    Installs OpenSSH Server, starts it on boot, and restricts its firewall rule
    to the Private profile (which includes Tailscale once set to Private).
    Use key-based login (add-ssh-key.ps1); it avoids Windows Hello password issues.

.EXAMPLE
    .\05-enable-ssh.ps1
#>

$ErrorActionPreference = "Stop"

$cap = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
if ($cap.State -ne "Installed") {
    Write-Host "Installing OpenSSH Server (this can take a minute)..."
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
}

Set-Service -Name sshd -StartupType Automatic
Start-Service sshd
Write-Host "OpenSSH Server is running and set to start automatically." -ForegroundColor Green

$rule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
if ($rule) {
    Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Profile Private
} else {
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (sshd)" `
                        -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Profile Private | Out-Null
}
Write-Host "SSH firewall rule limited to Private networks."
Write-Host "Next: .\add-ssh-key.ps1 -PublicKey `"<key from your Shortcut>`""
