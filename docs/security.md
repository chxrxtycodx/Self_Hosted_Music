# Security

## Threat model

This is a personal setup. The goal is that nobody outside your own devices can reach the server, and that a single leaked password doesn't expose the rest of the PC.

## What protects you

| Layer | Protection |
|---|---|
| No port forwarding | Navidrome and SMB are never reachable from the public internet |
| Tailscale (WireGuard) | All traffic between devices is encrypted, even though Navidrome uses plain `http://` |
| Tailscale membership | Only devices signed into your tailnet can connect |
| Navidrome login | Required to stream |
| Limited SMB account | Separate local user, access only to the music folder |
| Firewall rules | Scoped to the **Private** network profile |

## Do this

- **Turn on 2FA** for the identity provider you use with Tailscale (Google, Microsoft, GitHub, etc.). Your Tailscale login is the master key to your network.
- **Use strong, unique passwords** for Navidrome and the SMB account. Never reuse example passwords from tutorials.
- **Remove lost devices** from the Tailscale admin console immediately.
- **Use read-only SMB** unless you actually need uploads.
- **Keep software updated:** `winget upgrade Navidrome.Navidrome`, Tailscale, and Windows.

## Never do this

- **Never port-forward 445 (SMB) or 4533 (Navidrome) on your router.** Exposed SMB is one of the most attacked services on the internet; ransomware such as WannaCry spread through it. Use Tailscale for remote access.
- Don't add the sharing account to the Administrators group.
- Don't commit real IPs, usernames, passwords, or SSH keys to a public repo. `.gitignore` excludes local config by default.

## Removing everything

```powershell
.\scripts\uninstall.ps1 -ShareName Music
winget uninstall Navidrome.Navidrome
```
