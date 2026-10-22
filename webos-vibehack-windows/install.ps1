# Sync the TV's apps, package the launcher and install it on an LG TV in Developer Mode (Windows).
#   powershell -ExecutionPolicy Bypass -File install.ps1 -TvHost 192.168.1.50
# One-time setup (Developer Mode app open on the TV, Key Server on):
#   npx -y -p '@webos-tools/cli' ares-setup-device -a lgtv -i "{'host':'192.168.1.50','port':'9922','username':'prisoner'}"
#   npx -y -p '@webos-tools/cli' ares-novacom --device lgtv --getkey          # enter the passphrase shown on the TV
#   npx -y -p '@webos-tools/cli' ares-setup-device -m lgtv -i "{'privatekey':'lgtv_webos','passphrase':'<passphrase>'}"
param(
  [string]$TvHost = $env:TV_HOST,
  [string]$Device = $(if ($env:DEVICE) { $env:DEVICE } else { 'lgtv' })
)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not $TvHost) { throw 'Set the TV IP address, e.g. .\install.ps1 -TvHost 192.168.1.50' }
$AppId = 'com.gathin.tvhome'

# LG's webOS CLI: use it from PATH, otherwise fetch it with npx.
function Invoke-Ares([string]$Cmd, [string[]]$Rest) {
  if (Get-Command "ares-$Cmd" -ErrorAction SilentlyContinue) { & "ares-$Cmd" @Rest }
  else { & npx -y -p '@webos-tools/cli' "ares-$Cmd" @Rest }
  if ($LASTEXITCODE -ne 0) { throw "ares-$Cmd failed" }
}

$Py = Join-Path $PSScriptRoot 'venv\Scripts\python.exe'
if (-not (Test-Path $Py)) {
  python -m venv venv
  if ($LASTEXITCODE -ne 0) { throw 'Could not create venv: is Python 3 installed and on PATH?' }
  & $Py -m pip install -q websockets
}
& $Py sync-apps.py $TvHost
if ($LASTEXITCODE -ne 0) { throw 'sync-apps.py failed' }

if (-not (Test-Path app\icon.png)) {
  # The webOS app list wants PNG icons: 80px and 130px.
  Add-Type -AssemblyName System.Drawing
  $src = [System.Drawing.Image]::FromFile((Join-Path $PSScriptRoot 'assets\icon.jpg'))
  foreach ($icon in @(@('icon.png', 80), @('largeIcon.png', 130))) {
    $size = $icon[1]
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, 0, 0, $size, $size)
    $bmp.Save((Join-Path $PSScriptRoot "app\$($icon[0])"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
  }
  $src.Dispose()
}

if (Test-Path build) { Remove-Item -Recurse -Force build }
New-Item -ItemType Directory build | Out-Null
Invoke-Ares package @('app', '-o', 'build')
$ipk = (Get-ChildItem "build\$($AppId)_*.ipk" | Select-Object -First 1).FullName
Invoke-Ares install @('-d', $Device, $ipk)
Invoke-Ares launch @('-d', $Device, $AppId)
Write-Host 'Installed. Hold a number key on the remote while it is open to make it a one-press shortcut.'
