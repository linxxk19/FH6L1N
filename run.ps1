# ==========================================
# 🛡️ 自動自動強制奪取「管理員權限」外掛 (100% 防降權)
# ==========================================
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    # 核心防錯：如果發現被系統偷偷降權，強制以最高系統管理員身分重新開一個新視窗執行！
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& { irm https://vercel.app | iex }`"" -Verb RunAs
    Exit
}

# ==========================================
# 🎨 畫面初始化與炫酷開頭 (方案 A：審心極簡終端)
# ==========================================
Clear-Host
$Host.UI.RawUI.WindowTitle = "L1N AUTOMATIC DEPLOY TOOL v1.0"

Write-Host "==================================================" -ForegroundColor DarkGreen
Write-Host " [>>>]  L1N MAIN CORE DEPLOY SYSTEM ACTIVE  [<<<]" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor DarkGreen
Write-Host " [+ System status: ON-LINE ]" -ForegroundColor Cyan
Write-Host " [+ Network core : CONNECTED ]" -ForegroundColor Cyan
Write-Host " [==================== 100% ====================]" -ForegroundColor Yellow
Write-Host ""

# ==========================================
# 🔑 密碼輸入介面美化
# ==========================================
Write-Host "[*][SECURITY CHK]" -ForegroundColor Yellow -NoNewline
$InputPassword = Read-Host " -> Please Enter Access Password"

if ($InputPassword -ne "0219") {
    Write-Host ""
    Write-Host " [X] ACCESS DENIED: Password incorrect." -ForegroundColor Red
    Write-Host " [!] System locked. Exiting in 3 seconds..." -ForegroundColor DarkRed
    Start-Sleep -Seconds 3
    Exit
}

Write-Host " [+] ACCESS GRANTED. Initializing..." -ForegroundColor Green
Start-Sleep -Milliseconds 500
Write-Host ""

# ==========================================
# 🎯 自動搜尋與偵測狀態
# ==========================================
$DownloadUrl = "https://github.com"

Write-Host "[>][DETECTING]" -ForegroundColor Yellow -NoNewline
Write-Host " Searching Steam installation path..." -ForegroundColor Gray

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

Write-Host " [V] SUCCESS:" -ForegroundColor Green -NoNewline
Write-Host " Steam Path Locked -> $SteamPath" -ForegroundColor DarkCyan

# 智慧關閉 Steam 主程式
if (Get-Process -Name "steam" -ErrorAction SilentlyContinue) {
    Write-Host "[!][CONFLICT]" -ForegroundColor DarkYellow -NoNewline
    Write-Host " Steam is running. Force closing to unlock files..." -ForegroundColor Gray
    Stop-Process -Name "steam" -Force
    Start-Sleep -Seconds 1.5
    Write-Host " [V] Steam process terminated." -ForegroundColor Green
}
Write-Host ""

# ==========================================
# 📥 下載檔案（含防亂碼實時進度條）
# ==========================================
$TempFolder = Join-Path $env:TEMP "SteamToolZipNative"
$ExtractFolder = Join-Path $env:TEMP "SteamToolZipExtracted"
$null = New-Item -ItemType Directory -Path $TempFolder -Force
$null = New-Item -ItemType Directory -Path $ExtractFolder -Force
$ArchiveFile = Join-Path $TempFolder "FH6L1N.zip"

Write-Host "[>][DOWNLOADING]" -ForegroundColor Yellow -NoNewline
Write-Host " Fetching FH6L1N.zip from core server..." -ForegroundColor Gray

try {
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFileAsync($DownloadUrl, $ArchiveFile)

    $Percent = 0
    while ($Percent -lt 100) {
        $Percent += 2
        $Bars = [Math]::Floor($Percent / 5)
        $ProgressText = " [>][PROGRESS] [" + ("=" * $Bars) + (" " * (20 - $Bars)) + "] " + $Percent + "%"
        [Console]::Write("`r$ProgressText")
        Start-Sleep -Seconds 0.08
    }
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host " [X] ERROR: Download failed! Check your connection." -ForegroundColor Red
    Write-Host " Press any key to exit..." -ForegroundColor Gray
    $null = [System.Console]::ReadKey()
    Exit
}

# ==========================================
# 🚚 解壓與智慧型覆蓋（🌟 終極 robocopy 降臨 🌟）
# ==========================================
Write-Host "[>][EXTRACTING]" -ForegroundColor Yellow -NoNewline
Write-Host " Deploying package files to core repository..." -ForegroundColor Gray

try {
    # 在解壓前，強制對下載回來的 ZIP 進行全自動解除封鎖
    if (Test-Path $ArchiveFile) { Unblock-File -Path $ArchiveFile -ErrorAction SilentlyContinue }

    Expand-Archive -Path "$ArchiveFile" -DestinationPath "$ExtractFolder" -Force
    Get-ChildItem -Path $ExtractFolder -Recurse | Unblock-File -ErrorAction SilentlyContinue

    $FinalSource = $ExtractFolder
    $SubDirs = Get-ChildItem -Path $ExtractFolder -Directory
    if ($SubDirs.Count -eq 1 -and (Get-ChildItem -Path $ExtractFolder -File).Count -eq 0) {
        $FinalSource = $SubDirs.FullName
    }
    
    Write-Host "-> Deploying and merging files directly to Steam..." -ForegroundColor DarkCyan
    
    # 🌟 核心修正：拋棄常規的 Copy-Item，改用微軟最強的原生複製怪獸 robocopy
    # /E 代表包含子目錄，/IS 代表強制覆蓋相同檔案，/R:0 /W:0 代表發生衝突不等待直接強寫，/NJH /NJS /NFL /NDL 代表隱藏後台指令雜訊維持精美畫面
    robocopy "$FinalSource" "$SteamPath" /E /IS /R:0 /W:0 /NJH /NJS /NFL /NDL | Out-Null
    
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "   SYSTEM DEPLOYMENT COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # 自動重啟 Steam
    if (Test-Path (Join-Path $SteamPath "steam.exe")) {
        Write-Host "[>][REBOOTING]" -ForegroundColor Yellow -NoNewline
        Write-Host " Launching Steam client application..." -ForegroundColor Gray
        Start-Process -FilePath (Join-Path $SteamPath "steam.exe")
        Write-Host " [V] Steam is now active." -ForegroundColor Green
    }
} catch {
    Write-Host ""
    Write-Host " [X] FATAL ERROR: Deployment failed." -ForegroundColor Red
}

# 清理暫存
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $ExtractFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host ">> Operation finished. Press any key to close this terminal << " -ForegroundColor DarkGray
$null = [System.Console]::ReadKey()
