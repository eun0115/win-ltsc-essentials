@echo off
setlocal

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges. Restarting as admin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Get current directory
set "currentDir=%~dp0"

:: Check Windows version using PowerShell
for /f %%i in ('powershell -Command "[System.Environment]::OSVersion.Version.Build"') do set "build=%%i"

:: Continue with dependency and app installation (applies to all Windows versions)
echo Installing Native Runtime...
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.NET.Native.Runtime.1.7_1.7.27422.0_x64__8wekyb3d8bbwe.Appx'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.WindowsAppRuntime.1.5_5001.373.1736.0_x64__8wekyb3d8bbwe.Msix'"

echo Installing Xaml libraries...
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.UI.Xaml.2.4_2.42007.9001.0_x64__8wekyb3d8bbwe.Appx'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx'"

echo Installing VC Runtime Libraries...
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx'"

echo Installing Native Framework...
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.NET.Native.Framework.1.7_1.7.27413.0_x64__8wekyb3d8bbwe.Appx'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx'"

echo Installing Apps...
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.WindowsCamera_2021.105.10.0_neutral_~_8wekyb3d8bbwe.AppxBundle'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.Windows.Photos_2020.20120.4004.0_neutral_~_8wekyb3d8bbwe.AppxBundle'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.GamingApp_2403.1001.2.0_neutral_~_8wekyb3d8bbwe.Msixbundle'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.WindowsStore_12107.1001.15.0_neutral_~_8wekyb3d8bbwe.AppxBundle'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.WindowsAlarms_2022.2304.0.0_neutral_~_8wekyb3d8bbwe.Msixbundle'"
powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.WindowsTerminal_3001.22.11141.0_neutral_~_8wekyb3d8bbwe.Msixbundle'"

:: If Windows 11 (Build 22000+), remove legacy apps and install modern ones
if %build% GEQ 22000 (
    echo Detected Windows 11

:: Remove legacy apps
    echo Removing old Calculator and Notepad...
    Dism.exe /Online /NoRestart /Disable-Feature /FeatureName:Microsoft-Windows-win32calc /PackageName:@Package
    Dism.exe /Online /NoRestart /Remove-Capability /CapabilityName:Microsoft.Windows.Notepad~~~~0.0.1.0

:: Install
    echo Installing...
    powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.WindowsCalculator_2021.2502.2.0_neutral_~_8wekyb3d8bbwe.Msixbundle'"
    powershell -Command "Add-AppxPackage -Path '%currentDir%\Microsoft.WindowsNotepad_11.2503.16.0_neutral_~_8wekyb3d8bbwe.Msixbundle'"
    powershell -Command "Add-AppxPackage -Path '$PWD\Microsoft.ScreenSketch_2022.2508.29.0_neutral_~_8wekyb3d8bbwe.Msixbundle'"
) else (
    echo Detected Windows 10 or lower – skipping modern Calculator and Notepad install.
)

echo Activating
powershell -Command "irm https://get.activated.win | iex"

echo Adding Tweaks
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\893dee8e-2bef-41e0-89c6-b55d0929964c /v Attributes /t REG_DWORD /d 2 /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\bc5038f7-23e0-4960-96da-33abaf5935ec /v Attributes /t REG_DWORD /d 2 /f
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSecondsInSystemClock /t REG_DWORD /d 1 /f 
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\501a4d13-42af-4429-9fd1-a8218c268e20\ee12f906-d277-404b-b6da-e5fa1a576df5 /v Attributes /t REG_DWORD /d 2 /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\44f3beca-a7c0-460e-9df2-bb8b99e0cba6\3619c3f2-afb2-4afc-b0e9-e7fef372de36 /v Attributes /t REG_DWORD /d 2 /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\94D3A615-A899-4AC5-AE2B-E4D8F634367F /v Attributes /t REG_DWORD /d 2 /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\45bcc044-d885-43e2-8605-ee0ec6e96b59 /v Attributes /t REG_DWORD /d 2 /f

echo Installing Visual C++
powershell -Command "irm https://get.msvc.win | iex"

echo All tasks completed.

endlocal
pause
