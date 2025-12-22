@echo off
setlocal enabledelayedexpansion

echo ============================================
echo    KAIROS - Tests Infrastructure
echo ============================================
echo.

set PASSED=0
set FAILED=0
set TOTAL=0

:: Fonction pour afficher le resultat
goto :main

:test_result
set /a TOTAL+=1
if "%~1"=="PASS" (
    echo [PASS] %~2
    set /a PASSED+=1
) else (
    echo [FAIL] %~2
    set /a FAILED+=1
)
goto :eof

:main

echo [1/7] Verification Docker...
echo.

:: Test 1: Docker daemon running
docker info >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Docker daemon actif"
) else (
    call :test_result FAIL "Docker daemon non accessible"
    echo     Veuillez demarrer Docker Desktop
    goto :end
)

echo.
echo [2/7] Verification des containers...
echo.

:: Test containers
for %%c in (kairos-db kairos-kong kairos-auth kairos-rest kairos-n8n kairos-ollama kairos-nginx) do (
    docker ps --format "{{.Names}}" | findstr /C:"%%c" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        call :test_result PASS "Container %%c running"
    ) else (
        call :test_result FAIL "Container %%c non trouve"
    )
)

echo.
echo [3/7] Verification des ports...
echo.

:: Test ports (Windows netstat)
netstat -an | findstr ":3000.*LISTENING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Port 3000 (Kong) ouvert"
) else (
    call :test_result FAIL "Port 3000 (Kong) ferme"
)

netstat -an | findstr ":5678.*LISTENING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Port 5678 (n8n) ouvert"
) else (
    call :test_result FAIL "Port 5678 (n8n) ferme"
)

netstat -an | findstr ":11434.*LISTENING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Port 11434 (Ollama) ouvert"
) else (
    call :test_result FAIL "Port 11434 (Ollama) ferme"
)

netstat -an | findstr ":80.*LISTENING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Port 80 (Nginx) ouvert"
) else (
    call :test_result FAIL "Port 80 (Nginx) ferme"
)

echo.
echo [4/7] Test connexion PostgreSQL...
echo.

docker exec kairos-db pg_isready -U postgres >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "PostgreSQL pret"
) else (
    call :test_result FAIL "PostgreSQL non pret"
)

echo.
echo [5/7] Verification des tables...
echo.

docker exec kairos-db psql -U postgres -d postgres -c "\dt public.*" 2>nul | findstr "topics" >nul
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Table 'topics' existe"
) else (
    call :test_result FAIL "Table 'topics' non trouvee"
)

docker exec kairos-db psql -U postgres -d postgres -c "\dt public.*" 2>nul | findstr "articles" >nul
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Table 'articles' existe"
) else (
    call :test_result FAIL "Table 'articles' non trouvee"
)

echo.
echo [6/7] Test API Ollama...
echo.

curl -s -o nul -w "%%{http_code}" http://localhost:11434/api/tags 2>nul | findstr "200" >nul
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "API Ollama repond"
) else (
    call :test_result FAIL "API Ollama ne repond pas"
)

:: Verifier si le modele est charge
curl -s http://localhost:11434/api/tags 2>nul | findstr "gemma" >nul
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Modele Gemma charge"
) else (
    call :test_result FAIL "Modele Gemma non trouve"
)

echo.
echo [7/7] Test Frontend (Nginx)...
echo.

curl -s -o nul -w "%%{http_code}" http://localhost/ 2>nul | findstr "200" >nul
if %ERRORLEVEL% EQU 0 (
    call :test_result PASS "Frontend accessible"
) else (
    call :test_result FAIL "Frontend non accessible"
)

:end
echo.
echo ============================================
echo    RESULTATS
echo ============================================
echo.
echo   Tests passes:  %PASSED%
echo   Tests echoues: %FAILED%
echo   Total:         %TOTAL%
echo.

if %FAILED% EQU 0 (
    echo   [OK] Tous les tests sont passes!
) else (
    echo   [ATTENTION] %FAILED% test(s) ont echoue.
)

echo.
echo ============================================
pause
