# ==========================================
# 🔑 PASSWORD SETTING
# ==========================================
$CorrectPassword = "0219"

# Password prompt
$InputPassword = Read-Host "Enter Password"

if ($InputPassword -ne $CorrectPassword) {
    Write-Host "X Password Wrong! Exit." -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

# ==========================================
# 🎯 AUTOMATIC DEPLOY (.7Z NATIVE VERSION)
# ==========================================
$DownloadUrl = "https://github.com/linxxk19/FH6L1N/releases/download/FH6L1Nv1.0/FH6L1N.zip"

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

Write-Host "OK! Steam Path Locked" -ForegroundColor Green

# Create temp folder
$TempFolder = Join-Path $env:TEMP "SteamTool7zNative"
$null = New-Item -ItemType Directory -Path $TempFolder -Force
$ArchiveFile = Join-Path $TempFolder "FH6L1N.7z"

# Download 7z file
Write-Host "-> Downloading file from GitHub..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ArchiveFile -ErrorAction Stop
} catch {
    Write-Host "X Download Failed! Check your URL." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = [System.Console]::ReadKey()
    Exit
}

# Extracting via Windows Native tar.exe (Perfect for .7z)
Write-Host "-> Extracting file to Steam folder..." -ForegroundColor Yellow
try {
    # 使用 Windows 內建 tar 直接解壓 .7z 到 Steam 目錄
    tar -xf "$ArchiveFile" -C "$SteamPath"
    Write-Host "SUCCESS! Enjoy your game." -ForegroundColor Green
} catch {
    Write-Host "X Extraction Failed!" -ForegroundColor Red
}

# Cleanup
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "All done! Press any key to close this window..." -ForegroundColor Cyan
$null = [System.Console]::ReadKey()
