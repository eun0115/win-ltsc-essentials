# ===============================================================

# LTSC Essentials Installer - Fixed PowerShell Version

# ===============================================================

# Ensure running as administrator

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
Write-Host "This script requires administrator privileges. Restarting as admin..."
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
exit
}

# Create temporary working directory

$tempDir = Join-Path $env:TEMP "AppInstallerTemp"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }
Write-Host "Using temporary folder: $tempDir"

# ---------------------------------------------------------------

# Downloading package

# ---------------------------------------------------------------

function Download-App {
param([string]$Url)
$fileName = Split-Path $Url -Leaf
$dest = Join-Path $tempDir $fileName
if (-not (Test-Path $dest)) {
Write-Host "Downloading $fileName..."
Invoke-WebRequest -Uri $Url -OutFile $dest
} else {
Write-Host "$fileName already exists, skipping download."
}
return $dest
}

# ---------------------------------------------------------------

# Installing package

# ---------------------------------------------------------------

function Install-Package {
param([string]$Path)
Write-Host "Installing $Path..."
Add-AppxPackage -Path $Path -ErrorAction Stop
}

# ---------------------------------------------------------------

# Windows Detection

# ---------------------------------------------------------------

$osVersion = [System.Environment]::OSVersion.Version
$isWin11 = $false
if ($osVersion.Major -eq 10 -and $osVersion.Build -ge 22000) {
$isWin11 = $true
Write-Host "Windows 11 detected."
} else {
Write-Host "Skipping Windows 11 extras."
}

# ---------------------------------------------------------------

# Define required packages

# ---------------------------------------------------------------

$packages = @(
"[https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.GamingApp_2403.1001.2.0_neutral_._8wekyb3d8bbwe.Msixbundle](https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.GamingApp_2403.1001.2.0_neutral_._8wekyb3d8bbwe.Msixbundle)",
"[https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Framework.1.7_1.7.27413.0_x64__8wekyb3d8bbwe.Appx](https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Framework.1.7_1.7.27413.0_x64__8wekyb3d8bbwe.Appx)",
"[https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx](https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx)",
"[https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Runtime.1.7_1.7.27422.0_x64__8wekyb3d8bbwe.Appx](https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Runtime.1.7_1.7.27422.0_x64__8wekyb3d8bbwe.Appx)",
"[https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx](https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx)",
"[https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.ScreenSketch_2022.2508.29.0_neutral_._8wekyb3d8bbwe.Msixbundle](https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.ScreenSketch_2022.2508.29.0_neutral_._8wekyb3d8bbwe.Msixbundle)"
)

$win11Extras = @(
"[https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.ScreenSketch_2022.2508.29.0_neutral_._8wekyb3d8bbwe.Msixbundle](https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.ScreenSketch_2022.2508.29.0_neutral_._8wekyb3d8bbwe.Msixbundle)"
)

$allPackages = $packages
if ($isWin11) { $allPackages += $win11Extras }

# ---------------------------------------------------------------

# Download all packages

# ---------------------------------------------------------------

$downloadedPackages = @()
foreach ($pkgUrl in $allPackages) {
$downloadedPackages += Download-App $pkgUrl
}

# ---------------------------------------------------------------

# Install packages in order

# ---------------------------------------------------------------

foreach ($pkgPath in $downloadedPackages) {
try {
Install-Package $pkgPath
} catch {
# Fixed Write-Warning using string formatting
Write-Warning ("Failed to install {0}: {1}" -f $pkgPath, $_.Exception.Message)
}
}

Write-Host "All packages have been processed."
