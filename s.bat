@echo off
powershell.exe -NoLogo -NoProfile -NonInteractive ^
  -ExecutionPolicy Bypass ^
  -File "%~dp0script.ps1"
