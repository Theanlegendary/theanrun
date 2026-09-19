@echo off
cd /d "C:\Users\DELL\Desktop\daily_push"
title METFONE DAILY PUSH BOT
echo ===================================================
echo   DAILY PUSH BOT (WITH TOTAL PENDING REPORT)
echo ===================================================
echo Cleaning up any old bot instances...
taskkill /F /IM python.exe >nul 2>&1
timeout /t 1 >nul

echo Starting bot.py...
echo To stop the bot, press Ctrl + C
echo.
"C:\Users\DELL\AppData\Local\Programs\Python\Python312\python.exe" bot.py
echo.
echo Bot has stopped.
pause
