# ==========================================
# INITIALIZATION & DISPLAY INTERFACE
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
# SECURITY PASSWORD VERIFICATION
# ==========================================
Write-Host "[*][SECURITY CHK]" -ForegroundColor Yellow -NoNewline
$InputPassword = Read-Host " -> Please Enter Access Password"

if ($InputPassword -ne "0219") {
    Write-Host "X Password Wrong! Exit." -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

Write-Host " [+] ACCESS GRANTED. Initializing..." -ForegroundColor Green
Start-Sleep -Milliseconds 500
Write-Host ""

# ==========================================
# PATH DETECTION & AUTOMATIC DEPLOY
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

if (Get-Process -Name "steam" -ErrorAction SilentlyContinue) {
    Write-Host "-> Closing Steam to unlock files..." -ForegroundColor Yellow
    Stop-Process -Name "steam" -Force
    Start-Sleep -Seconds 2
}

$TempFolder = Join-Path $env:TEMP "SteamToolZipNative"
$ExtractFolder = Join-Path $env:TEMP "SteamToolZipExtracted"
$null = New-Item -ItemType Directory -Path $TempFolder -Force
$null = New-Item -ItemType Directory -Path $ExtractFolder -Force
$ArchiveFile = Join-Path $TempFolder "FH6L1N.zip"

Write-Host "-> Downloading file from GitHub..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ArchiveFile -ErrorAction Stop
} catch {
    Write-Host "X Download Failed! Check your URL." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = [System.Console]::ReadKey()
    Exit
}

Write-Host "-> Extracting file..." -ForegroundColor Yellow
try {
    if (Test-Path $ArchiveFile) { Unblock-File -Path $ArchiveFile -ErrorAction SilentlyContinue }

    Expand-Archive -Path "$ArchiveFile" -DestinationPath "$ExtractFolder" -Force
    Get-ChildItem -Path $ExtractFolder -Recurse | Unblock-File -ErrorAction SilentlyContinue
    
    $FinalSource = $ExtractFolder
    $SubDirs = Get-ChildItem -Path $ExtractFolder -Directory
    if ($SubDirs.Count -eq 1 -and (Get-ChildItem -Path $ExtractFolder -File).Count -eq 0) {
        $FinalSource = $SubDirs.FullName
    }
    
    Write-Host "-> Deploying and merging files directly to Steam..." -ForegroundColor Cyan
    robocopy "$FinalSource" "$SteamPath" /E /IS /R:0 /W:0 /NJH /NJS /NFL /NDL | Out-Null
    
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "   SYSTEM DEPLOYMENT COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (Test-Path (Join-Path $SteamPath "steam.exe")) {
        # 🌟 這裡已將 🔄 圖標剔除，改成標準純文字，永遠告別亂碼！
        Write-Host "-> Restarting Steam..." -ForegroundColor Cyan
        Start-Process -FilePath (Join-Path $SteamPath "steam.exe")
    }
} catch {
    Write-Host "X Extraction or Move Failed! Make sure you run PowerShell as Administrator." -ForegroundColor Red
}

Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $ExtractFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host ">> Operation finished. Press any key to close this terminal << " -ForegroundColor DarkGray
$null = [System.Console]::ReadKey()
