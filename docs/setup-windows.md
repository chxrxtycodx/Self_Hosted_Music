# Setup (Windows host)

Total time is about 30–45 minutes, plus however long it takes to organize your music.

Placeholders used throughout:

| Placeholder | Replace with |
|---|---|
| `<you>` | Your Windows user folder name (run `whoami` and use the part after `\`) |
| `<music-folder>` | Full path to your library, e.g. `C:\Users\<you>\Music\Library` |
| `<tailscale-ip>` | Your PC's Tailscale address (starts with `100.`) |

> All PowerShell commands marked **(Admin)** must run in an elevated terminal: right-click **Start**, choose **Terminal (Admin)**, and click **Yes**. The title bar should say *Administrator*.

---

## 1. Prepare the music folder

1. Create one folder for your library, e.g. `C:\Users\<you>\Music\Library`.
2. Add your music files (MP3, M4A, FLAC, OGG, etc.).
3. Optional: clean tags with [MusicBrainz Picard](https://picard.musicbrainz.org/) or [beets](https://beets.io/) so albums and artwork display correctly.

**Why:** this folder *is* the library. Navidrome reads it; nothing gets copied elsewhere.

## 2. Keep the PC awake

**Settings → System → Power & battery → Screen and sleep**, set sleep to **Never** when plugged in.

**Why:** if the PC sleeps, the server goes offline and playback stops.

## 3. Install Tailscale

1. Install Tailscale on the PC from [tailscale.com/download](https://tailscale.com/download) and sign in.
2. Install it on your phone and sign in with the **same account**.
3. Find the PC's address: click the Tailscale tray icon (by the clock, possibly under **^**). It starts with `100.`. This is `<tailscale-ip>`.
4. **(Admin)** Mark the Tailscale network as Private so Windows Firewall allows local services on it:
   ```powershell
   Set-NetConnectionProfile -InterfaceAlias Tailscale -NetworkCategory Private
   ```

**Why:** Tailscale lets your phone reach the PC from anywhere without exposing anything to the internet.

## 4. Install Navidrome

**(Admin)**
```powershell
winget install Navidrome.Navidrome --interactive
```

`--interactive` shows the installer prompts. When asked:
- **Music folder:** `<music-folder>`
- **Port:** `4533` (default)

Navidrome installs as a Windows service and starts automatically on boot.

> If you install without `--interactive`, the installer may run silently and point at an empty default folder. Fix it with `scripts/04-configure-navidrome.ps1`.

## 5. Configure Navidrome and the firewall

From the repo folder, **(Admin)**:
```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\03-navidrome-firewall.ps1
.\scripts\04-configure-navidrome.ps1 -MusicFolder "<music-folder>"
```

## 6. Create your Navidrome account

1. On the PC, open `http://localhost:4533`.
2. Create an admin username and a **strong** password.
3. Wait for the first scan. Your library appears within a minute or two depending on size.

## 7. Connect your phone

**iPhone: Amperfy** (free, App Store)
- Server URL: `http://<tailscale-ip>:4533`
- Username / password: your Navidrome account

**Other clients (Subsonic API):**
- iPhone: substreamer, play:Sub
- Android: Tempo (free), Symfonium (paid)
- Desktop: Feishin
- Any browser on a Tailscale device: `http://<tailscale-ip>:4533`

Keep Tailscale switched on on the phone.

## 8. Optional extras

- Upload music from your phone: [remote-upload.md](remote-upload.md)
- Minimal no-server option: [smb-vlc.md](smb-vlc.md)
- Hardening: [security.md](security.md)

## Playlists

- Create playlists in Amperfy (long-press a song → **Add to Playlist**) or in the Navidrome web UI. They sync both ways.
- Navidrome auto-imports `.m3u` / `.m3u8` playlist files found in the music folder.
- To migrate playlists from another service, export the track list (e.g. with Exportify as CSV), then buy or rip the tracks and build the playlist from your own files.
