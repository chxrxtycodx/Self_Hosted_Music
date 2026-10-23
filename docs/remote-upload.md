# Add music from your phone

Two ways to get new files into the library while away from the PC.

## Option A: iOS Files app over SMB (recommended)

Uses the SMB share with **write** access.

1. **(Admin)** Create the share with write access:
   ```powershell
   .\scripts\01-create-share-user.ps1
   .\scripts\02-create-smb-share.ps1 -MusicFolder "<music-folder>" -ShareName Music -AllowWrite
   ```
2. On the iPhone: **Files → ⋯ → Connect to Server**, enter `smb://<tailscale-ip>`, and log in with the sharing account.
3. Copy purchased or ripped files into the share. Navidrome picks them up on its next scheduled scan, or trigger one from the web UI (**Settings → Library → Scan**, label varies by version).

Typical flow: buy an album on Bandcamp on your phone → download the files → copy them into the share from Files.

## Option B: iOS Shortcut over SSH (advanced)

Run commands on the PC from a Shortcut, such as organizing new files, re-tagging with beets, or kicking off a library scan.

### 1. Enable SSH on the PC

**(Admin)**
```powershell
.\scripts\05-enable-ssh.ps1
```

### 2. Build the Shortcut

In the Shortcuts app, add **Run Script over SSH**:

| Field | Value |
|---|---|
| Host | `<tailscale-ip>` |
| Port | `22` |
| User | your Windows username |
| Authentication | **SSH Key** → tap the key and copy the public key |
| Script | a command of your choice (see examples) |

### 3. Authorize the phone's key

**(Admin)**, paste the public key from the Shortcut:
```powershell
.\scripts\add-ssh-key.ps1 -PublicKey "ssh-ed25519 AAAA... iphone"
```

Key-based login also sidesteps the Windows Hello password issue.

### Example scripts

Move files from a Downloads folder into the library:
```
move /Y "%USERPROFILE%\Downloads\*.mp3" "C:\Users\<you>\Music\Library\Inbox\"
```

Import and tag new files with beets (if installed):
```
beet import -q "C:\Users\<you>\Music\Library\Inbox"
```

> Only add content you have the rights to. See [legal.md](legal.md).

## Option C: Taildrop

Tailscale's built-in file sending. Files land in the PC's Downloads folder and need to be moved into the library manually (or with a Shortcut from Option B).
