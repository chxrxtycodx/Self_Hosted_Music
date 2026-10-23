#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Allows inbound connections to Navidrome on Private networks only.

.DESCRIPTION
    The rule is scoped to the Private profile, which includes the Tailscale
    adapter once it is set to Private. Public networks (e.g. coffee shop Wi-Fi)
    stay blocked. This does NOT open anything on your router.

.PARAMETER Port
    Navidrome port. Default: 4533

.EXAMPLE
    .\03-navidrome-firewall.ps1
#>
param(
    [int]$Port = 4533
)

$ErrorActionPreference = "Stop"
$ruleName = "Navidrome"

if (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue) {
    Write-Host "Firewall rule '$ruleName' already exists." -ForegroundColor Yellow
} else {
    New-NetFirewallRule -DisplayName $ruleName `
                        -Direction Inbound `
                        -Protocol TCP `
                        -LocalPort $Port `
                        -Action Allow `
                        -Profile Private | Out-Null
    Write-Host "Created firewall rule '$ruleName' (TCP $Port, Private profile only)." -ForegroundColor Green
}

$ts = Get-NetConnectionProfile -InterfaceAlias "Tailscale" -ErrorAction SilentlyContinue
if (-not $ts) {
    Write-Warning "Tailscale adapter not found. Install Tailscale and sign in, then re-run this script."
} elseif ($ts.NetworkCategory -ne "Private") {
    Set-NetConnectionProfile -InterfaceAlias "Tailscale" -NetworkCategory Private
    Write-Host "Set the Tailscale network profile to Private."
}
