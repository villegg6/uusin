# Muistiinpanot (Claude-keskustelusta 2026-10-22)

## Ympäristö
- Kotikone: **Windows**, Claude Desktop asennettu (tumma tila).
- Paikalliset asiat (TV, Jellyfin) pitää tehdä **paikallisessa** Claude Code -istunnossa (Desktop → Code → New session → Local), ei pilvi-istunnossa.

## LG TV + webos-vibehack (Apple TV -tyylinen käynnistin)
- Alkuperäinen repo: https://github.com/OmkarK97/webos-vibehack
- Windows-paketti tässä repossa, haara `claude/pensive-babbage-3w3o3c`:
  `webos-vibehack-windows/` ja `webos-vibehack-windows.zip`
  (lisätty `install.ps1`, `home-watch-windows.ps1`, UTF-8-korjaus `sync-apps.py`:hin, ohje `WINDOWS-OHJE.md`).
- Lataus PowerShellillä:
  ```powershell
  cd $HOME\Desktop
  Invoke-WebRequest "https://raw.githubusercontent.com/villegg6/uusin/claude/pensive-babbage-3w3o3c/webos-vibehack-windows.zip" -OutFile webos-vibehack-windows.zip
  Expand-Archive webos-vibehack-windows.zip -DestinationPath . -Force
  ```
- TV: Wi-Fi-IP **10.239.130.237**, Developer Mode päällä (sessio ~999 h). Passphrase näkyy TV:n Developer Mode -sovelluksessa.
- Tila: **ei vielä asennettu**. Seuraavaksi: ares-setup-device → ares-novacom --getkey → `install.ps1 -TvHost 10.239.130.237` → `home-watch-windows.ps1`.

## Jellyfin + Radarr
- Jellyfin pyörii **Windowsilla** (http://localhost:8096).
- Tavoite: lisätä **Radarr** (https://github.com/Radarr/Radarr) ja kytkeä Jellyfiniin.
- Tila: **ei vielä asennettu**. Vaiheet:
  1. Asenna Radarr (GitHub releases, `*windows-core-x64-installer.exe`), UI http://localhost:7878.
  2. Radarr: Settings → Media Management → Root Folder = Jellyfinin elokuvakansio.
  3. Jellyfin: Hallintapaneeli → API-avaimet → luo avain "Radarr".
  4. Radarr: Settings → Connect → Emby / Jellyfin: localhost, 8096, API-avain, Update Library, On Import + On Upgrade.
  5. Haluttaessa indexer (Prowlarr) ja latausohjelma (qBittorrent).
