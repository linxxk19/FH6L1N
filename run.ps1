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
# 🎯 AUTOMATIC DEPLOY (.ZIP PERFECT FLAT VERSION)
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

Write-Host "OK! Steam Path Locked: $SteamPath" -ForegroundColor Green

# 🌟 核心防錯：如果 Steam 正在執行，直接強制關閉它以釋放檔案鎖定
if (Get-Process -Name "steam" -ErrorAction SilentlyContinue) {
    Write-Host "⚠️ Detecting Steam is running. Closing Steam to unlock files..." -ForegroundColor Yellow
    Stop-Process -Name "steam" -Force
    Start-Sleep -Seconds 2 # 等待系統完全釋放鎖定
}

# 建立暫存資料夾
$TempFolder = Join-Path $env:TEMP "SteamToolZipNative"
$ExtractFolder = Join-Path $TempFolder "Extracted"
$null = New-Item -ItemType Directory -Path $ExtractFolder -Force
$ArchiveFile = Join-Path $TempFolder "FH6L1N.zip"

# 下載 zip 檔案
Write-Host "-> Downloading file from GitHub..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ArchiveFile -ErrorAction Stop
} catch {
    Write-Host "X Download Failed! Check your URL." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = [System.Console]::ReadKey()
    Exit
}

# 解壓到暫存區並覆蓋
Write-Host "-> Extracting file..." -ForegroundColor Yellow
try {
    Expand-Archive -Path "$ArchiveFile" -DestinationPath "$ExtractFolder" -Force
    
    # 智慧型平鋪檔案移動
    $SubDirs = Get-ChildItem -Path $ExtractFolder -Directory
    if ($SubDirs.Count -eq 1 -and (Get-ChildItem -Path $ExtractFolder -File).Count -eq 0) {
        $SourcePath = $SubDirs.FullName
        Write-Host "-> Flattening folder contents directly to Steam..." -ForegroundColor Cyan
        Get-ChildItem -Path "$SourcePath\*" | Move-Item -Destination "$SteamPath" -Force
    } else {
        Write-Host "-> Moving files directly to Steam..." -ForegroundColor Cyan
        Get-ChildItem -Path "$ExtractFolder\*" | Move-Item -Destination "$SteamPath" -Force
    }
    
    Write-Host "SUCCESS! Enjoy your game." -ForegroundColor Green
    
    # 🌟 貼心自動化：部署成功後，自動幫朋友把 Steam 重新開起來！
    if (Test-Path (Join-Path $SteamPath "steam.exe")) {
        Write-Host "🔄 Restarting Steam..." -ForegroundColor Cyan
        Start-Process -FilePath (Join-Path $SteamPath "steam.exe")
    }
} catch {
    Write-Host "X Extraction or Move Failed! Make sure you run PowerShell as Administrator." -ForegroundColor Red
}

# 清理所有暫存
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "All done! Press any key to close this window..." -ForegroundColor Cyan
$null = [System.Console]::ReadKey()
