@echo off
echo Copying database setup to clipboard...
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed or not in PATH
    echo Please install Python or run the setup manually
    pause
    exit /b 1
)

REM Install pyperclip if not available
python -c "import pyperclip" >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing pyperclip...
    pip install pyperclip
)

REM Run the Python script
python copy_database_setup.py

echo.
echo Press any key to continue...
pause >nul

