@echo off
REM =============================================================================
REM KAIROS - Setup Script (Windows)
REM =============================================================================

echo.
echo ===============================================================
echo                     KAIROS - Setup
echo            Plateforme de Veille Intelligente
echo ===============================================================
echo.

REM Check Docker
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop.
    pause
    exit /b 1
)
echo [OK] Docker is installed

REM Check if Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop.
    pause
    exit /b 1
)
echo [OK] Docker is running

REM Get project root
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

REM Create directories
echo.
echo [INFO] Creating directories...
if not exist "%PROJECT_ROOT%\supabase\migrations" mkdir "%PROJECT_ROOT%\supabase\migrations"
if not exist "%PROJECT_ROOT%\n8n\workflows" mkdir "%PROJECT_ROOT%\n8n\workflows"
echo [OK] Directories created

REM Setup .env
echo.
echo [INFO] Setting up environment...
if not exist "%PROJECT_ROOT%\docker\.env" (
    if exist "%PROJECT_ROOT%\docker\.env.example" (
        copy "%PROJECT_ROOT%\docker\.env.example" "%PROJECT_ROOT%\docker\.env"
        echo [OK] Created .env from .env.example
        echo [!] Please review and update docker\.env with your settings
    ) else (
        echo [ERROR] .env.example not found
        pause
        exit /b 1
    )
) else (
    echo [OK] .env file already exists
)

REM Pull Docker images
echo.
echo [INFO] Pulling Docker images (this may take a while)...
cd "%PROJECT_ROOT%\docker"
docker-compose pull

REM Start services
echo.
echo [INFO] Starting services...
docker-compose up -d

REM Download Ollama model
echo.
echo [INFO] Downloading Gemma 3 model (this may take a while)...
echo Waiting for Ollama to start...
timeout /t 15 /nobreak >nul
docker exec kairos-ollama ollama pull gemma3:4b

echo.
echo ===============================================================
echo                     Setup Complete!
echo ===============================================================
echo.
echo Services available at:
echo   Frontend:      http://localhost:3000
echo   Supabase API:  http://localhost:8000
echo   n8n:           http://localhost:5678 (admin/kairos2024)
echo   Ollama:        http://localhost:11434
echo.
echo Next steps:
echo   1. Review docker\.env and update passwords
echo   2. Access n8n at http://localhost:5678
echo   3. Import workflows from n8n\workflows\
echo.
pause
