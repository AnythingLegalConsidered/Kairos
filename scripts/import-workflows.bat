@echo off
REM =============================================================================
REM KAIROS - Import automatique des workflows n8n
REM =============================================================================
setlocal enabledelayedexpansion

echo.
echo ================================================
echo    KAIROS - Import des Workflows n8n
echo ================================================
echo.

REM Configuration
set N8N_URL=http://localhost:5678
set N8N_USER=admin
set N8N_PASSWORD=kairos2024
set WORKFLOWS_DIR=%~dp0..\n8n\workflows

REM Verifier que n8n est accessible
echo [1/4] Verification de n8n...
curl -s -o nul -w "%%{http_code}" %N8N_URL%/healthz > temp_status.txt
set /p STATUS=<temp_status.txt
del temp_status.txt

if not "%STATUS%"=="200" (
    echo [ERREUR] n8n n'est pas accessible sur %N8N_URL%
    echo Assurez-vous que les conteneurs Docker sont demarres:
    echo   cd docker ^&^& docker-compose up -d
    pause
    exit /b 1
)
echo [OK] n8n est accessible

REM Afficher les instructions manuelles
echo.
echo [2/4] Import des workflows...
echo.
echo ================================================
echo    INSTRUCTIONS D'IMPORT MANUEL
echo ================================================
echo.
echo L'import automatique via API necessite une configuration
echo supplementaire. Veuillez importer manuellement:
echo.
echo 1. Ouvrez n8n: %N8N_URL%
echo    - Login: %N8N_USER%
echo    - Password: %N8N_PASSWORD%
echo.
echo 2. Cliquez sur "..." puis "Import from File"
echo.
echo 3. Importez ces fichiers:
echo    - %WORKFLOWS_DIR%\rss_processor.json
echo    - %WORKFLOWS_DIR%\cleanup.json
echo    - %WORKFLOWS_DIR%\notifications.json
echo.
echo 4. IMPORTANT: Configurez la variable d'environnement
echo    - Allez dans Settings ^> Variables
echo    - Ajoutez: SUPABASE_SERVICE_KEY
echo    - Valeur: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1sb2NhbCIsInJvbGUiOiJzZXJ2aWNlX3JvbGUiLCJleHAiOjE5ODM4MTI5OTZ9.CvGPVcSrdWNqg71tF_g4YKevVDnN4F2WdoXh3ce0T7k
echo.
echo 5. Activez chaque workflow apres l'import
echo.
echo ================================================
echo.

REM Ouvrir n8n dans le navigateur
echo [3/4] Ouverture de n8n dans le navigateur...
start "" %N8N_URL%

echo.
echo [4/4] Verification du modele Ollama...
docker exec kairos-ollama ollama list 2>nul | findstr /i "gemma" >nul
if errorlevel 1 (
    echo [INFO] Le modele gemma3:4b n'est pas installe.
    echo        Telechargement en cours (environ 3 GB)...
    docker exec kairos-ollama ollama pull gemma3:4b
    echo [OK] Modele telecharge
) else (
    echo [OK] Modele gemma3:4b present
)

echo.
echo ================================================
echo    Configuration terminee!
echo ================================================
echo.
echo N'oubliez pas d'activer les workflows dans n8n.
echo.
pause
