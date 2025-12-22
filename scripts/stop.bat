@echo off
REM =============================================================================
REM KAIROS - Stop Script (Windows)
REM =============================================================================

echo [INFO] Stopping Kairos services...

set "SCRIPT_DIR=%~dp0"
cd "%SCRIPT_DIR%..\docker"

docker-compose down

echo.
echo [OK] All services stopped.
echo.
