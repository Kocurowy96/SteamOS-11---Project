@echo off

REM Add a shortcut to app.bat in Windows startup
set startupFolder=%appdata%\Microsoft\Windows\Start Menu\Programs\Startup
set appPath=C:\SteamOS11\bin\APP\RUNNER\app.bat
set shortcutPath=%startupFolder%\SteamOS11.lnk

if exist "%shortcutPath%" (
    echo Shortcut already exists in autorun.
) else (
    echo Creating shortcut to app.bat in autorun...
    powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%shortcutPath%'); $s.TargetPath = '%appPath%'; $s.WorkingDirectory = '%~dp0'; $s.Save()"
    if exist "%shortcutPath%" (
        echo Shortcut created successfully.
    ) else (
        echo Failed to create shortcut.
    )
)
exit /b