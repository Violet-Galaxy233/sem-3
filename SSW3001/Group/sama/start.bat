@echo off
REM SamaRasa Startup Script for Windows

echo ==============================================
echo   SamaRasa - AI Elderly Care Assistant
echo ==============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo X Python is not installed.
    echo Please install Python 3.8 or higher from https://www.python.org
    pause
    exit /b 1
)

echo + Python found
echo.

REM Check and install dependencies
echo Checking dependencies...
pip show Flask >nul 2>&1
if errorlevel 1 (
    echo Installing dependencies...
    pip install -r requirements.txt
) else (
    echo + Dependencies installed
)

echo.
echo ==============================================
echo Starting SamaRasa Backend Server...
echo ==============================================
echo.
echo Elderly Interface: http://localhost:5000
echo Family Dashboard: http://localhost:5000/dashboard
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the Flask server
cd backend
python app.py
