# ===============================================================
# LTSC Essentials Installer - PowerShell Version
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
}

# ---------------------------------------------------------------
# Define required packages
# ---------------------------------------------------------------
$packages = @(
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.GamingApp_2403.1001.2.0_neutral_._8wekyb3d8bbwe.Msixbundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Framework.1.7_1.7.27413.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Runtime.1.7_1.7.27422.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.ScreenSketch_2022.2508.29.0_neutral_._8wekyb3d8bbwe.Msixbundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.UI.Xaml.2.4_2.42007.9001.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.Windows.Photos_2020.20120.4004.0_neutral_._8wekyb3d8bbwe.AppxBundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsAlarms_2022.2304.0.0_neutral_._8wekyb3d8bbwe.Msixbundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsAppRuntime.1.5_5001.373.1736.0_x86__8wekyb3d8bbwe.Msix",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsCalculator_2021.2502.2.0_neutral_._8wekyb3d8bbwe.Msixbundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsCamera_2021.105.10.0_neutral_._8wekyb3d8bbwe.AppxBundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsStore_12107.1001.15.0_neutral_._8wekyb3d8bbwe.AppxBundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsTerminal_3001.22.11141.0_neutral_._8wekyb3d8bbwe.Msixbundle"
)

$win11Extras = @(
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.ScreenSketch_2022.2508.29.0_neutral_._8wekyb3d8bbwe.Msixbundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsCalculator_2021.2502.2.0_neutral_._8wekyb3d8bbwe.Msixbundle",
    "https://github.com/eun0115/win-ltsc-essentials/releases/download/1.0/Microsoft.WindowsNotepad_11.2503.16.0_neutral_._8wekyb3d8bbwe.Msixbundle"
)

# Combine packages
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
# Install packages
# ---------------------------------------------------------------
foreach ($pkgPath in $downloadedPackages) {
    try {
        Install-Package $pkgPath
    } catch {
        Write-Warning ("Failed to install {0}: {1}" -f $pkgPath, $_)
    }
}

Write-Host "All packages have been processed."
