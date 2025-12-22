@echo off
REM =============================================================================
REM KAIROS - Start Script (Windows)
REM =============================================================================

echo [INFO] Starting Kairos services...

set "SCRIPT_DIR=%~dp0"
cd "%SCRIPT_DIR%..\docker"

docker-compose up -d

echo.
echo [OK] All services started!
echo.
echo Services:
echo   Frontend:      http://localhost:3000
echo   Supabase API:  http://localhost:8000
echo   n8n:           http://localhost:5678
echo   Ollama:        http://localhost:11434
echo.
