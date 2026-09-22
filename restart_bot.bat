@echo off
echo ============================================================
echo 🔄 RESTARTING BOT WITH NEW FILTERING CODE
echo ============================================================
echo.
echo 1. Looking for running Python processes...
echo.

REM Kill any running bot processes
tasklist | find /I "python.exe" >nul
if %ERRORLEVEL% EQU 0 (
    echo ⚠️  Found running Python processes
    echo.
    echo Please MANUALLY stop the bot:
    echo   1. Go to the terminal running the bot
    echo   2. Press Ctrl+C to stop
    echo   3. Then run this script again
    echo.
    pause
    exit /b
)

echo ✅ No Python processes found
echo.
echo 2. Starting bot with NEW code...
echo.

cd /d "%~dp0"
python bot.py

pause
