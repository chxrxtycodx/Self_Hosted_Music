# Troubleshooting

## `System error 5` / `Access is denied`
The terminal isn't elevated. Open **Terminal (Admin)** and confirm the title bar says *Administrator*.

## `No mapping between account names and security IDs was done`
The account you referenced doesn't exist. Usually the user-creation step failed (often because of the error above). Re-run `01-create-share-user.ps1` as admin.

## `New-SmbShare : The system cannot find the file specified`
The folder path is wrong. Check the exact name and location:
```powershell
Get-ChildItem "$env:USERPROFILE\Music"
```
If your Music folder is synced by OneDrive, the path may be `C:\Users\<you>\OneDrive\Music\...`.

## SMB login keeps asking for credentials
- If you sign into Windows with **Windows Hello or a passkey**, your Microsoft account password may not work over the network. Use a local sharing account (`01-create-share-user.ps1`).
- If you recently changed your Microsoft password, the PC keeps the old one until you sign into Windows once with the new password.
- Some clients need the format `COMPUTERNAME;username` or `COMPUTERNAME\username`.

## Connects at home but not remotely
- You're using the PC-name entry, which only resolves on the local network. Connect to `<tailscale-ip>` instead.
- Tailscale is off on the phone.
- The Tailscale adapter is set to **Public**. Fix **(Admin)**:
  ```powershell
  Set-NetConnectionProfile -InterfaceAlias Tailscale -NetworkCategory Private
  ```

## Navidrome shows no songs
- The installer ran silently and used a default empty folder. Run:
  ```powershell
  .\scripts\04-configure-navidrome.ps1 -MusicFolder "<music-folder>"
  ```
- Files lack tags. Navidrome groups by tags, not folder names. Tag with Picard or beets.

## No Windows installer on the GitHub release page
The asset list collapses. Click **Show all assets**, or install with `winget install Navidrome.Navidrome --interactive`.

## Amperfy can't connect
- Use `http://`, not `https://`, and include the port: `http://<tailscale-ip>:4533`.
- Confirm the firewall rule exists: `Get-NetFirewallRule -DisplayName Navidrome`.
- Test from the PC first: `http://localhost:4533`.

## Music stops after a while
The PC went to sleep, restarted for Windows Update, or lost power. Set sleep to **Never** and consider setting Active Hours in Windows Update.
