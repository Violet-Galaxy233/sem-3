#!/bin/bash

# SamaRasa Startup Script

echo "=============================================="
echo "  SamaRasa - AI Elderly Care Assistant"
echo "=============================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null
then
    echo "❌ Python 3 is not installed."
    echo "Please install Python 3.8 or higher from https://www.python.org"
    exit 1
fi

echo "✓ Python found: $(python3 --version)"
echo ""

# Check if dependencies are installed
echo "Checking dependencies..."
pip3 show Flask &> /dev/null
if [ $? -ne 0 ]; then
    echo "📦 Installing dependencies..."
    pip3 install -r requirements.txt
else
    echo "✓ Dependencies installed"
fi

echo ""
echo "=============================================="
echo "Starting SamaRasa Backend Server..."
echo "=============================================="
echo ""
echo "🌐 Elderly Interface: http://localhost:5000"
echo "👨‍👩‍👧 Family Dashboard: http://localhost:5000/dashboard"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the Flask server
cd backend
python3 app.py
