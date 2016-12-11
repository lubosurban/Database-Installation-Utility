@echo off

pushd "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0\.scripts\UpdateDatabase.ps1' %*;
pause
popd