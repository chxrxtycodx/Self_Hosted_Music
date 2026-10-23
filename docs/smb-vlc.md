# Minimal option: SMB share + VLC

No music server. Your phone opens the PC's music folder like a file browser and plays files directly. Good for a quick start; Navidrome is the better daily experience.

## Steps

1. Complete steps 1–3 of [setup-windows.md](setup-windows.md) (folder, power, Tailscale).
2. **(Admin)** Create a limited sharing account and share the folder:
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\01-create-share-user.ps1
   .\scripts\02-create-smb-share.ps1 -MusicFolder "<music-folder>" -ShareName Music
   ```
3. On the phone, open **VLC → Browse → File Servers → Connect**.
   - Protocol: **SMB**
   - Server: `<tailscale-ip>`
   - Port: leave blank (SMB uses 445)
   - Username / password: the sharing account from step 2
   - Workgroup: leave blank
4. Open the share, tap a song, and VLC plays through the folder.

**Tip:** long-press the folder and choose **Add to Favorites** for quick access.

## Why a separate account?

If you sign into Windows with **Windows Hello or a passkey**, your Microsoft account password may not work for network logins. SMB can't use Hello or passkeys. A local account with its own password avoids this, and it can be limited to read-only access on the music folder.

## Limits

- VLC is a file browser: no library view, artwork grid, or synced playlists.
- The PC must stay on and awake.
- A device listed under *File Servers* by PC name only works on your home network. Use the Tailscale IP for remote access.
