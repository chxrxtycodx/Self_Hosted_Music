# Architecture

The setup has four parts. Each does one job.

## 1. Music folder: the library

One folder on the PC holds every song. Whatever is in this folder shows up on your phone. Organize it as `Artist/Album/Track` if you can, and keep the tags (artist, album, artwork) clean. Navidrome reads the tags, not the folder names.

## 2. Navidrome: the server

Navidrome runs in the background on the PC as a Windows service. It scans the music folder, builds a library from the tags, and serves it at port `4533`.

It speaks the **Subsonic API**, so any Subsonic-compatible app can use it. It also has a built-in web player.

> Why: it's your own Spotify server. It turns a folder of files into a browsable music service.

## 3. Tailscale: the private network

Tailscale gives every device you sign in a private `100.x.x.x` address. Those devices can reach each other from anywhere, over encrypted WireGuard tunnels, without opening router ports.

> Why: it links your phone and PC as if they were on the same Wi-Fi, even when you're out.

Tailscale and Navidrome don't know about each other. Navidrome answers whoever reaches it, and Tailscale gets only your devices there.

**Is Tailscale "the cloud"?** No. Your files never leave the PC. Tailscale's servers only help your devices find each other. When a direct connection isn't possible, traffic is relayed through Tailscale's servers but stays end-to-end encrypted.

## 4. Amperfy: the client

Amperfy is a free, open-source iOS player for Subsonic servers. It connects to `http://<tailscale-ip>:4533` and gives you albums, playlists, search, and optional offline downloads.

## Optional: SMB share (uploads)

A Windows file share on the music folder, accessed with a limited local account. The iOS Files app can connect to it and copy new songs in. Navidrome picks them up on its next scan.

## Data flow

```
Phone (Amperfy) ──Tailscale──> PC:4533 (Navidrome) ──reads──> Music folder
Phone (Files)   ──Tailscale──> PC:445  (SMB share) ──writes─> Music folder
```
