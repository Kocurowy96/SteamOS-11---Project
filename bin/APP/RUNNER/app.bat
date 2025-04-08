@echo off

:: Load settings from settings.txt
set settingsFile=%~dp0..\settings.txt
if not exist "%settingsFile%" (
    echo Creating default settings file...
    echo autorun-timeout=1 > "%settingsFile%"
    echo autorun=true >> "%settingsFile%"
)

for /f "tokens=1,2 delims==" %%a in ('type "%settingsFile%"') do (
    set %%a=%%b
)

:menu
cls
echo ============================================
echo SteamOS 11 - Application Runner
echo ============================================
echo 1. Launch Steam in Big Picture Mode
echo 2. View Current Settings
echo 3. Edit Settings
echo 4. Exit
echo 5. Reset Settings to Default
echo 6. View Logs
echo ============================================
set /p choice=Select an option (1-6): 

if "%choice%"=="1" (
    echo Launching Steam in Big Picture Mode...
    if exist "C:\Program Files (x86)\Steam\steam.exe" (
        start "C:\Program Files (x86)\Steam\steam.exe" -start steam://open/bigpicture
        call :log Steam launched successfully
    ) else (
        echo Steam is not installed or not found in the default location.
        call :log Steam launch failed: steam.exe not found
        pause
        goto menu
    )
    timeout /t %autorun-timeout% >nul
    goto menu
) else if "%choice%"=="2" (
    call :viewSettings
    goto menu
) else if "%choice%"=="3" (
    call :editSettings
    goto menu
) else if "%choice%"=="4" (
    echo Exiting...
    timeout /t 1 >nul
    goto menu
) else if "%choice%"=="5" (
    call :resetSettings
    goto menu
) else if "%choice%"=="6" (
    call :viewLogs
    goto menu
) else (
    echo Invalid choice. Please try again.
    timeout /t 2 >nul
    goto menu
)

:viewSettings
cls
echo ============================================
echo Current Settings:
echo ============================================
for /f "tokens=1,2 delims==" %%a in ('type "%settingsFile%"') do (
    echo %%a=%%b
)
echo ============================================
pause
goto menu

:editSettings
cls
echo ============================================
echo Edit Settings
echo ============================================
echo Current Settings:
for /f "tokens=1,2 delims==" %%a in ('type "%settingsFile%"') do (
    echo %%a=%%b
)
echo ============================================
set /p settingKey=Enter the setting key to edit or add: 
set /p settingValue=Enter the new value: 

:: Update or add the setting
(for /f "tokens=1,2 delims==" %%a in ('type "%settingsFile%"') do (
    if /i "%%a"=="%settingKey%" (
        set found=true
        echo %settingKey%=%settingValue%
    ) else (
        echo %%a=%%b
    )
)) > "%settingsFile%.tmp"

if not defined found (
    echo %settingKey%=%settingValue% >> "%settingsFile%.tmp"
)

move /y "%settingsFile%.tmp" "%settingsFile%" >nul
echo Setting updated or added successfully!
pause
goto menu

:resetSettings
cls
echo ============================================
echo Resetting settings to default values...
echo ============================================
echo autorun-timeout=1 > "%settingsFile%"
echo autorun=true >> "%settingsFile%"
echo Settings have been reset to default values.
pause
goto menu

:viewLogs
cls
echo ============================================
echo Application Logs:
echo ============================================
if exist "%~dp0..\log.txt" (
    type "%~dp0..\log.txt"
) else (
    echo No logs available.
)
echo ============================================
pause
goto menu

:log
echo [%date% %time%] %* >> "%~dp0..\log.txt"
exit /b