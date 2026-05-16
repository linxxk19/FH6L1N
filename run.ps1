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
# 📥 下載檔案（🌟 換成 100% 防閃退實時文字讀條核心 🌟）
# ==========================================
$TempFolder = Join-Path $env:TEMP "SteamToolZipNative"
$ExtractFolder = Join-Path $env:TEMP "SteamToolZipExtracted"
$null = New-Item -ItemType Directory -Path $TempFolder -Force
$null = New-Item -ItemType Directory -Path $ExtractFolder -Force
$ArchiveFile = Join-Path $TempFolder "FH6L1N.zip"

Write-Host "[>][DOWNLOADING]" -ForegroundColor Yellow -NoNewline
Write-Host " Fetching FH6L1N.zip from core server..." -ForegroundColor Gray

try {
    # 🌟 改用 HttpClient 同步下載核心，防止系統強制搶先執行結尾
    $HttpClient = New-Object System.Net.Http.HttpClient
    $Response = $HttpClient.GetAsync($DownloadUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
    
    if (-not $Response.IsSuccessStatusCode) { throw "Download Error" }
    
    $TotalBytes = $Response.Content.Headers.ContentLength
    $Stream = $Response.Content.ReadAsStreamAsync().Result
    $FileStream = [System.IO.File]::Create($ArchiveFile)
    $Buffer = New-Object byte[] 4096
    $BytesRead = 0
    $TotalBytesRead = 0

    while (($BytesRead = $Stream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
        $FileStream.Write($Buffer, 0, $BytesRead)
        $TotalBytesRead += $BytesRead
        
        if ($TotalBytes) {
            # 精準計算百分比並每 5% 亮一格方塊 (共 20 格)
            $Percent = [Math]::Floor(($TotalBytesRead / $TotalBytes) * 100)
            $Bars = [Math]::Floor($Percent / 5)
            $ProgressText = " [>][PROGRESS] [" + ("█" * $Bars) + ("░" * (20 - $Bars)) + "] " + $Percent + "%"
            [Console]::Write("`r$ProgressText")
        }
    }

    $FileStream.Close()
    $Stream.Close()
    $HttpClient.Dispose()
    Write-Host "" # 下載完畢換行
} catch {
    Write-Host ""
    Write-Host " [X] ERROR: Download failed! Check your connection or GitHub URL." -ForegroundColor Red
    Write-Host " Press any key to exit..." -ForegroundColor Gray
    $null = [System.Console]::ReadKey()
    Exit
}

# ==========================================
# 🚚 解壓與智慧型覆蓋
# ==========================================
Write-Host "[>][EXTRACTING]" -ForegroundColor Yellow -NoNewline
Write-Host " Deploying package files to core repository..." -ForegroundColor Gray

try {
    Expand-Archive -Path "$ArchiveFile" -DestinationPath "$ExtractFolder" -Force
    
    $FinalSource = $ExtractFolder
    $SubDirs = Get-ChildItem -Path $ExtractFolder -Directory
    if ($SubDirs.Count -eq 1 -and (Get-ChildItem -Path $ExtractFolder -File).Count -eq 0) {
        $FinalSource = $SubDirs.FullName
    }
    
    Write-Host "-> Deploying and merging files directly to Steam..." -ForegroundColor DarkCyan
    Copy-Item -Path "$FinalSource\*" -Destination "$SteamPath" -Recurse -Force
    
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
    Write-Host " Please right-click PowerShell and run as Administrator!" -ForegroundColor Yellow
}

# 清理暫存
Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $ExtractFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host ">> Operation finished. Press any key to close this terminal << " -ForegroundColor DarkGray
$null = [System.Console]::ReadKey()
