# Asennus Windowsilla

Tarvitset: **Node.js** (nodejs.org) ja **Python 3** (python.org, rasti kohtaan "Add python.exe to PATH").
Kone ja TV samassa verkossa.

## 1. TV (kerran)
1. Luo ilmainen tili: https://webostv.developer.lge.com
2. Asenna TV:lle LG Content Storesta **Developer Mode** ja kirjaudu.
3. Laita **Dev Mode Status** päälle (TV käynnistyy uudelleen), avaa sovellus uudestaan ja laita **Key Server** päälle.
4. Kirjoita ylös **IP-osoite** ja **Passphrase**.

## 2. Yhdistä kone TV:hen (kerran)
Avaa PowerShell tässä kansiossa (Shift + hiiren oikea → "Avaa PowerShell-ikkuna tässä") ja aja,
vaihtaen IP:n ja passphrasen omiksi:

```powershell
npx -y -p '@webos-tools/cli' ares-setup-device -a lgtv -i "{'host':'192.168.1.50','port':'9922','username':'prisoner'}"
npx -y -p '@webos-tools/cli' ares-novacom --device lgtv --getkey
npx -y -p '@webos-tools/cli' ares-setup-device -m lgtv -i "{'privatekey':'lgtv_webos','passphrase':'ABC123'}"
```
(Toinen komento kysyy passphrasen.)

## 3. Asenna käynnistin
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -TvHost 192.168.1.50
```
Hyväksy TV:llä "salli laite?" -kysely. Aja sama komento uudelleen aina kun lisäät tai poistat sovelluksia TV:ltä.

## 4. (Valinnainen) Home-nappi käynnistimeen
Pitää tämän koneen taustalla vahtimassa; käynnistyy aina kirjautuessa:
```powershell
powershell -ExecutionPolicy Bypass -File home-watch-windows.ps1 -TvHost 192.168.1.50
```
Poisto: `powershell -ExecutionPolicy Bypass -File home-watch-windows.ps1 -Uninstall`
Loki: `%LOCALAPPDATA%\tv-vibehack-home-watch.log`. Toimii vain kun kone on päällä.
Jos Windowsin palomuuri kysyy Pythonin verkkolupaa, salli yksityinen verkko.
