# ========================================
# Komorebi + YASB Installation Script
# Run as Administrator
# ========================================

# Check admin rights
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Run PowerShell as Administrator!"
    Exit
}

Write-Host "Installing Komorebi + YASB..." -ForegroundColor Cyan

# Enable long paths support
Write-Host "[1/3] Enabling long paths..." -ForegroundColor Yellow
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# Install Komorebi and whkd
Write-Host "[2/3] Installing Komorebi and whkd..." -ForegroundColor Yellow
winget install --id LGUG2Z.komorebi --accept-package-agreements --accept-source-agreements
winget install --id LGUG2Z.whkd --accept-package-agreements --accept-source-agreements

# Install YASB
Write-Host "[3/3] Installing YASB..." -ForegroundColor Yellow
winget install --id AmN.yasb --accept-package-agreements --accept-source-agreements

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "
IMPORTANT:
1. Install fonts:
   - JetBrains Mono: https://www.jetbrains.com/lp/mono/
   - JetBrains Mono Nerd Font: https://www.nerdfonts.com/font-downloads

2. Restart PowerShell and run:
   komorebic quickstart
   Copy-Item -Path '.\MySetup\Windows\komorebi\*' -Destination '$env:USERPROFILE' -Recurse -Force
   Copy-Item -Path '.\MySetup\Windows\yasb' -Destination '$env:USERPROFILE\.config' -Recurse -Force
   komorebic enable-autostart --whkd
   komorebic start --whkd

" -ForegroundColor Yellow

Read-Host "Press Enter to exit"
