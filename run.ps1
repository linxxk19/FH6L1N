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
# 🎯 AUTOMATIC DEPLOY (.7Z PERFECT VERSION)
# ==========================================
# ⚠️ 請確保下方的下載網址是您上傳的最新 .7z 網址
$DownloadUrl = https://github.com/linxxk19/FH6L1N/releases/download/FH6L1Nv1.0/FH6L1N.7z"

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

# 建立獨立暫存資料夾
$TempFolder = Join-Path $env:TEMP "SteamTool7zTemp"
$null = New-Item -ItemType Directory -Path $TempFolder -Force
$ArchiveFile = Join-Path $TempFolder "FH6L1N.7z"

# 📥 下載您的 .7z 主檔案（加入錯誤安全檢查，防止閃退）
Write-Host "-> Downloading .7z file from GitHub..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ArchiveFile -ErrorAction Stop
} catch {
    Write-Host "`n❌ 下載失敗！原因可能是您程式碼第 15 行的 `$DownloadUrl 網址填錯了。" -ForegroundColor Red
    Write-Host "❌ 請確認您的 GitHub Release 中，.7z 檔案的下載連結是否真的與它一模一樣。`n" -ForegroundColor Yellow
    Write-Host "請按任意鍵關閉此視窗..."
    $null = [System.Console]::ReadKey()
    Exit
}

# 🧰 背景下載官方 7-Zip 免安裝獨立執行檔
Write-Host "-> Preparing 7-Zip core..." -ForegroundColor Cyan
$7zExe = Join-Path $TempFolder "7za.exe"
$7zUrl = "https://7-zip.org"
$7zZip = Join-Path $TempFolder "7za.zip"
Invoke-WebRequest -Uri $7zUrl -OutFile $7zZip
Expand-Archive -Path $7zZip -DestinationPath $TempFolder -Force

# 🚚 執行強制解壓縮與覆蓋
Write-Host "-> Extracting .7z file to Steam folder..." -ForegroundColor Yellow
if (Test-Path $7zExe) {
    & $7zExe x "$ArchiveFile" "-o$SteamPath" -y | Out-Null
} else {
    Write-Host "X 7-Zip Core Missing! Extraction failed." -ForegroundColor Red
    Write-Host "請按任意鍵關閉此視窗..."
    $null = [System.Console]::ReadKey()
    Exit
}

# ✨ 清理所有暫存檔案
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "SUCCESS! Enjoy your game." -ForegroundColor Green

# 🌟 成功後停留畫面，不直接關閉
Write-Host "`n全部流程已順利完成！請按任意鍵關閉此視窗..." -ForegroundColor Cyan
$null = [System.Console]::ReadKey()
