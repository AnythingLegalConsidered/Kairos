@echo off
REM =============================================================================
REM KAIROS - Reset Script (Windows)
REM =============================================================================

echo.
echo ===============================================================
echo                    WARNING - DESTRUCTIVE
echo      This will delete ALL data including database!
echo ===============================================================
echo.

set /p confirm="Are you sure you want to reset everything? (yes/no): "

if /i not "%confirm%"=="yes" (
    echo [INFO] Reset cancelled.
    pause
    exit /b 0
)

set "SCRIPT_DIR=%~dp0"
cd "%SCRIPT_DIR%..\docker"

echo.
echo [INFO] Stopping all services...
docker-compose down

echo [INFO] Removing volumes...
docker-compose down -v

echo [INFO] Removing orphan containers...
docker-compose down --remove-orphans

echo.
echo [OK] Reset complete!
echo.
echo Run scripts\setup.bat to reinitialize the environment.
echo.
pause
