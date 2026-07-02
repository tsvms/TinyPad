@echo off
reg delete "HKCU\Software\Classes\.tpad" /f >nul 2>&1
reg delete "HKCU\Software\Classes\.txt\ShellNew" /f >nul 2>&1
reg delete "HKCU\Software\Classes\TinyPadFile" /f >nul 2>&1

reg add "HKCU\Software\Classes\.txt" /ve /d "TinyPadFile" /f >nul
reg add "HKCU\Software\Classes\.txt\ShellNew" /v "NullFile" /t REG_SZ /f >nul
reg add "HKCU\Software\Classes\TinyPadFile" /ve /d "TinyPad" /f >nul
reg add "HKCU\Software\Classes\TinyPadFile\DefaultIcon" /ve /d "%SystemRoot%\system32\imageres.dll,-102" /f >nul
reg add "HKCU\Software\Classes\TinyPadFile\shell\open\command" /ve /d "\"%~dp0TinyPad.exe\" \"%%1\"" /f >nul

powershell "$wshell = New-Object -COM WScript.Shell; $s1 = $wshell.CreateShortcut('%USERPROFILE%\Desktop\TinyPad.lnk'); $s1.TargetPath='%~dp0TinyPad.exe'; $s1.IconLocation='%SystemRoot%\system32\imageres.dll,-102'; $s1.WorkingDirectory='%~dp0'; $s1.Save(); $s2 = $wshell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\TinyPad.lnk'); $s2.TargetPath='%~dp0TinyPad.exe'; $s2.IconLocation='%SystemRoot%\system32\imageres.dll,-102'; $s2.WorkingDirectory='%~dp0'; $s2.Save()"

taskkill /f /im explorer.exe >nul
start explorer.exe
exit