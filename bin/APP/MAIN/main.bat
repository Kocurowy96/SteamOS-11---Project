@echo off

REM This script is used to initialize the SteamOS 11 environment.
REM It sets up the necessary environment variables and configurations.
REM Author: Kocurowy96
REM Date: 2025-04-07

:: Request administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please run it as an administrator.
    pause
    goto main
)

set version=1.0.0
set build=2025.04.07
set name=SteamOS 11 Initialization
set os=Windows 11
set arch=x64
set path=%~dp0
set logFile=%~dp0..\install.log

title %name% %version% %build%

:main
cls
echo.
echo %name% %version% %build%
echo.
echo This script initializes the SteamOS 11 environment.
echo It sets up the necessary environment variables and configurations.
echo.
echo Author: Kocurowy96
echo Date: 2025-04-07
echo.
timeout /t 2 >nul

:: Check required tools
call :checkTools

:: Create a backup of the bin folder
call :backupBin

:: Initialize environment
echo Initializing SteamOS 11 environment...
call :log Initializing environment...
echo.
echo Setting up environment variables...
set STEAMOS11_HOME=%path%
timeout /t 1 >nul
echo Setting up system configurations...

:: Ask user for Steam version
set steamUrl=
set /p steamVersion=Which version of Steam do you want to install? (stable/beta): 
if /i "%steamVersion%"=="beta" (
    set steamUrl=https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetupBeta.exe
    echo Selected version: Beta
) else (
    set steamUrl=https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe
    echo Selected version: Stable
)

:: Copy the bin folder to C:\
echo Copying bin folder to C:\...
xcopy "%~dp0..\..\bin" "C:\bin" /E /I /Y >nul
if %errorlevel% neq 0 (
    call :handleError "Failed to copy the bin folder."
    goto main
)

:: Navigate to C:\
cd /d C:\

:: Create the SteamOS11 folder
echo Creating SteamOS11 folder in C:\...
mkdir SteamOS11 >nul
if %errorlevel% neq 0 (
    call :handleError "Failed to create the SteamOS11 folder."
    goto main
)

:: Move the bin folder to SteamOS11
echo Moving bin folder to C:\SteamOS11...
move /y "C:\bin" "C:\SteamOS11" >nul
if %errorlevel% neq 0 (
    call :handleError "Failed to move the bin folder to SteamOS11."
    goto main
)

:: Download Steam installer to bin folder
echo Checking if Steam installer is already downloaded...
if not exist "%~dp0..\..\bin\SteamSetup.exe" (
    echo Downloading Steam installer to bin folder...
    powershell -Command "Invoke-WebRequest -Uri '%steamUrl%' -OutFile '%~dp0..\..\bin\SteamSetup.exe'"
    if exist "%~dp0..\..\bin\SteamSetup.exe" (
        echo Steam installer downloaded successfully.
    ) else (
        call :handleError "Failed to download Steam installer."
        goto main
    )
) else (
    echo Steam installer already exists in the bin folder.
)

:: Install Steam
echo Checking if Steam is installed...
if not exist "C:\Program Files (x86)\Steam\steam.exe" (
    echo Running Steam installer...
    start /wait "%~dp0..\..\bin\SteamSetup.exe"
    if %errorlevel% neq 0 (
        call :handleError "Steam installation failed."
        goto main
    )
    echo Steam installation completed.
) else (
    echo Steam is already installed.
)

:: Cleanup temporary files
call :cleanup

echo.
echo SteamOS 11 environment setup completed successfully!
call :log Setup completed successfully.
pause
goto main

:checkTools
echo Checking required tools...
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    call :handleError "PowerShell is not available."
    goto main
)
where xcopy >nul 2>&1
if %errorlevel% neq 0 (
    call :handleError "XCOPY is not available."
    goto main
)
echo All required tools are available.
exit /b

:backupBin
echo Creating a backup of the bin folder...
if not exist "C:\SteamOS11\bin_backup" (
    mkdir "C:\SteamOS11\bin_backup"
)
xcopy "C:\SteamOS11\bin" "C:\SteamOS11\bin_backup" /E /I /Y >nul
if %errorlevel% neq 0 (
    call :handleError "Failed to create a backup of the bin folder."
    goto main
)
echo Backup created successfully.
exit /b

:cleanup
echo Cleaning up temporary files...
if exist "%~dp0..\..\bin\SteamSetup.exe" (
    del /f /q "%~dp0..\..\bin\SteamSetup.exe"
    echo Steam installer removed.
)
echo Cleanup completed.
exit /b

:handleError
echo An error occurred: %*
call :log Error: %*
pause
exit /b

:log
echo [%date% %time%] %* >> "%logFile%"
exit /b

