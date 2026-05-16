# ==========================================
# 🔑 PASSWORD SETTING
# ==========================================
$CorrectPassword = "0219"

# Password prompt
$InputPassword = Read-Host "Enter Password"

if ($InputPassword -ne $CorrectPassword) {
    Write-Host "X Password Wrong! Exit." -ForegroundColor Red
    Exit
}

# ==========================================
# 🎯 AUTOMATIC DEPLOY
# ==========================================
$DownloadUrl = "https://github.com"

Write-Host "-> Searching Steam installation path..." -ForegroundColor Cyan
$SteamPath = $null
$RegPaths = @("HKCU:\Software\Valve\Steam", "HKLM:\SOFTWARE\Wow6432Node\Valve\Steam", "HKLM:\SOFTWARE\Valve\Steam")

foreach ($RegPath in $RegPaths) {
    if (Test-Path $RegPath) {
        $SteamPath = (Get-ItemProperty -Path $RegPath -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
        if ($SteamPath) { break }
    }
}

if (-not $SteamPath) { 
    if (Test-Path "D:\Steam") { $SteamPath = "D:\Steam" }
    elseif (Test-Path "D:\Program Files (x86)\Steam") { $SteamPath = "D:\Program Files (x86)\Steam" }
    else { $SteamPath = "C:\Program Files (x86)\Steam" }
}

Write-Host "OK! Steam Path Locked: $SteamPath" -ForegroundColor Green

# Download and Extract
$TempFile = Join-Path $env:TEMP "FH6L1N.rar"
Write-Host "-> Downloading file from GitHub..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempFile

Write-Host "-> Extracting file to Steam folder..." -ForegroundColor Yellow
tar -xf $TempFile -C $SteamPath

Remove-Item $TempFile -ErrorAction SilentlyContinue
Write-Host "SUCCESS! Enjoy your game." -ForegroundColor Green
