# Run home-watch.py in the background on this Windows PC: starts at login, no console window.
#   powershell -ExecutionPolicy Bypass -File home-watch-windows.ps1 -TvHost 192.168.1.50   # install / update
#   powershell -ExecutionPolicy Bypass -File home-watch-windows.ps1 -Uninstall
# Log: %LOCALAPPDATA%\tv-vibehack-home-watch.log
param(
  [string]$TvHost = $env:TV_HOST,
  [switch]$Uninstall
)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$Shortcut = Join-Path ([Environment]::GetFolderPath('Startup')) 'tv-vibehack-home-watch.lnk'
$Log = Join-Path $env:LOCALAPPDATA 'tv-vibehack-home-watch.log'

# Stop a watcher that is already running.
Get-CimInstance Win32_Process -Filter "Name = 'pythonw.exe'" |
  Where-Object { $_.CommandLine -like '*home-watch.py*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

if ($Uninstall) {
  Remove-Item -Force -ErrorAction SilentlyContinue $Shortcut
  Write-Host "Removed. Home opens LG's home again."
  exit 0
}
if (-not $TvHost) { throw 'Set the TV IP address, e.g. .\home-watch-windows.ps1 -TvHost 192.168.1.50' }

$Py = Join-Path $PSScriptRoot 'venv\Scripts\python.exe'
if (-not (Test-Path $Py)) {
  python -m venv venv
  if ($LASTEXITCODE -ne 0) { throw 'Could not create venv: is Python 3 installed and on PATH?' }
}
& $Py -m pip install -q websockets
$Pyw = Join-Path $PSScriptRoot 'venv\Scripts\pythonw.exe'

# pythonw has no console, so send the watcher's output to the log file.
$Code = "import sys,runpy; sys.stdout=sys.stderr=open(r'$Log','a',buffering=1,encoding='utf-8'); " +
        "sys.argv=['home-watch.py','$TvHost']; runpy.run_path('home-watch.py', run_name='__main__')"
$PyArgs = "-u -c `"$Code`""

$lnk = (New-Object -ComObject WScript.Shell).CreateShortcut($Shortcut)
$lnk.TargetPath = $Pyw
$lnk.Arguments = $PyArgs
$lnk.WorkingDirectory = $PSScriptRoot
$lnk.Save()

Start-Process -FilePath $Pyw -ArgumentList $PyArgs -WorkingDirectory $PSScriptRoot
Write-Host "Watching $TvHost. It starts again at every login. Log: $Log"
