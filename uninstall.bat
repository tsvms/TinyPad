@echo off
reg delete "HKCU\Software\Classes\.txt" /ve /f >nul 2>&1
reg delete "HKCU\Software\Classes\.txt\ShellNew" /f >nul 2>&1
reg delete "HKCU\Software\Classes\TinyPadFile" /f >nul 2>&1
del "%USERPROFILE%\Desktop\TinyPad.lnk" >nul 2>&1
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\TinyPad.lnk" >nul 2>&1

taskkill /f /im explorer.exe >nul
start explorer.exe
exit