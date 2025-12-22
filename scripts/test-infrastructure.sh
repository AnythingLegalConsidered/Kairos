#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================"
echo "   KAIROS - Tests Infrastructure"
echo "============================================"
echo ""

PASSED=0
FAILED=0
TOTAL=0

# Fonction pour afficher le resultat
test_result() {
    ((TOTAL++))
    if [ "$1" == "PASS" ]; then
        echo -e "${GREEN}[PASS]${NC} $2"
        ((PASSED++))
    else
        echo -e "${RED}[FAIL]${NC} $2"
        ((FAILED++))
    fi
}

echo "[1/7] Verification Docker..."
echo ""

# Test 1: Docker daemon running
if docker info > /dev/null 2>&1; then
    test_result "PASS" "Docker daemon actif"
else
    test_result "FAIL" "Docker daemon non accessible"
    echo "    Veuillez demarrer Docker"
    exit 1
fi

echo ""
echo "[2/7] Verification des containers..."
echo ""

# Test containers
for container in kairos-db kairos-kong kairos-auth kairos-rest kairos-n8n kairos-ollama kairos-nginx; do
    if docker ps --format "{{.Names}}" | grep -q "$container"; then
        test_result "PASS" "Container $container running"
    else
        test_result "FAIL" "Container $container non trouve"
    fi
done

echo ""
echo "[3/7] Verification des ports..."
echo ""

# Test ports
check_port() {
    if nc -z localhost $1 2>/dev/null || lsof -i :$1 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

if check_port 3000; then
    test_result "PASS" "Port 3000 (Kong) ouvert"
else
    test_result "FAIL" "Port 3000 (Kong) ferme"
fi

if check_port 5678; then
    test_result "PASS" "Port 5678 (n8n) ouvert"
else
    test_result "FAIL" "Port 5678 (n8n) ferme"
fi

if check_port 11434; then
    test_result "PASS" "Port 11434 (Ollama) ouvert"
else
    test_result "FAIL" "Port 11434 (Ollama) ferme"
fi

if check_port 80; then
    test_result "PASS" "Port 80 (Nginx) ouvert"
else
    test_result "FAIL" "Port 80 (Nginx) ferme"
fi

echo ""
echo "[4/7] Test connexion PostgreSQL..."
echo ""

if docker exec kairos-db pg_isready -U postgres > /dev/null 2>&1; then
    test_result "PASS" "PostgreSQL pret"
else
    test_result "FAIL" "PostgreSQL non pret"
fi

echo ""
echo "[5/7] Verification des tables..."
echo ""

if docker exec kairos-db psql -U postgres -d postgres -c "\dt public.*" 2>/dev/null | grep -q "topics"; then
    test_result "PASS" "Table 'topics' existe"
else
    test_result "FAIL" "Table 'topics' non trouvee"
fi

if docker exec kairos-db psql -U postgres -d postgres -c "\dt public.*" 2>/dev/null | grep -q "articles"; then
    test_result "PASS" "Table 'articles' existe"
else
    test_result "FAIL" "Table 'articles' non trouvee"
fi

echo ""
echo "[6/7] Test API Ollama..."
echo ""

if curl -s -o /dev/null -w "%{http_code}" http://localhost:11434/api/tags 2>/dev/null | grep -q "200"; then
    test_result "PASS" "API Ollama repond"
else
    test_result "FAIL" "API Ollama ne repond pas"
fi

# Verifier si le modele est charge
if curl -s http://localhost:11434/api/tags 2>/dev/null | grep -q "gemma"; then
    test_result "PASS" "Modele Gemma charge"
else
    test_result "FAIL" "Modele Gemma non trouve"
fi

echo ""
echo "[7/7] Test Frontend (Nginx)..."
echo ""

if curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null | grep -q "200"; then
    test_result "PASS" "Frontend accessible"
else
    test_result "FAIL" "Frontend non accessible"
fi

echo ""
echo "============================================"
echo "   RESULTATS"
echo "============================================"
echo ""
echo "  Tests passes:  $PASSED"
echo "  Tests echoues: $FAILED"
echo "  Total:         $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "  ${GREEN}[OK] Tous les tests sont passes!${NC}"
else
    echo -e "  ${YELLOW}[ATTENTION] $FAILED test(s) ont echoue.${NC}"
fi

echo ""
echo "============================================"
