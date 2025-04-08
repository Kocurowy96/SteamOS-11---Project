@echo off

:: Load settings from settings.txt
set settingsFile=%~dp0..\settings.txt
if not exist "%settingsFile%" (
    echo Creating default settings file...
    echo autorun-timeout=1 > "%settingsFile%"
    echo autorun=true >> "%settingsFile%"
    echo steam-path=C:\Program Files (x86)\Steam >> "%settingsFile%"
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
echo 4. Change Steam Location
echo 5. Reset Settings to Default
echo 6. View Logs
echo 7. Exit
echo ============================================
set /p choice=Select an option (1-7): 

if "%choice%"=="1" (
    echo Launching Steam in Big Picture Mode...
    if exist "%steam-path%\steam.exe" (
        start "%steam-path%\steam.exe" -start steam://open/bigpicture
        call :log Steam launched successfully
    ) else (
        echo Steam is not installed or not found in the specified location: %steam-path%.
        call :log Steam launch failed: steam.exe not found in %steam-path%.
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
    call :changeSteamPath
    goto menu
) else if "%choice%"=="5" (
    call :resetSettings
    goto menu
) else if "%choice%"=="6" (
    call :viewLogs
    goto menu
) else if "%choice%"=="7" (
    echo Exiting...
    timeout /t 1 >nul
    exit /b
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

:changeSteamPath
cls
echo ============================================
echo Change Steam Location
echo ============================================
echo Current Steam Path: %steam-path%
set /p newSteamPath=Enter the new Steam installation path: 
if not exist "%newSteamPath%\steam.exe" (
    echo The specified path does not contain steam.exe. Please try again.
    pause
    goto changeSteamPath
)
(for /f "tokens=1,2 delims==" %%a in ('type "%settingsFile%"') do (
    if /i "%%a"=="steam-path" (
        echo steam-path=%newSteamPath%
    ) else (
        echo %%a=%%b
    )
)) > "%settingsFile%.tmp"
move /y "%settingsFile%.tmp" "%settingsFile%" >nul
set steam-path=%newSteamPath%
echo Steam path updated successfully to: %steam-path%
pause
goto menu

:resetSettings
cls
echo ============================================
echo Resetting settings to default values...
echo ============================================
echo autorun-timeout=1 > "%settingsFile%"
echo autorun=true >> "%settingsFile%"
echo steam-path=C:\Program Files (x86)\Steam >> "%settingsFile%"
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