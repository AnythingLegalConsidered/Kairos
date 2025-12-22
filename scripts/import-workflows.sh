#!/bin/bash
# =============================================================================
# KAIROS - Import automatique des workflows n8n
# =============================================================================

set -e

echo ""
echo "================================================"
echo "   KAIROS - Import des Workflows n8n"
echo "================================================"
echo ""

# Configuration
N8N_URL="http://localhost:5678"
N8N_USER="admin"
N8N_PASSWORD="kairos2024"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$SCRIPT_DIR/../n8n/workflows"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifier que n8n est accessible
echo "[1/4] Verification de n8n..."
if curl -s -o /dev/null -w "%{http_code}" "$N8N_URL/healthz" | grep -q "200"; then
    echo -e "${GREEN}[OK]${NC} n8n est accessible"
else
    echo -e "${RED}[ERREUR]${NC} n8n n'est pas accessible sur $N8N_URL"
    echo "Assurez-vous que les conteneurs Docker sont demarres:"
    echo "  cd docker && docker-compose up -d"
    exit 1
fi

# Afficher les instructions manuelles
echo ""
echo "[2/4] Import des workflows..."
echo ""
echo "================================================"
echo "   INSTRUCTIONS D'IMPORT MANUEL"
echo "================================================"
echo ""
echo "L'import automatique via API necessite une configuration"
echo "supplementaire. Veuillez importer manuellement:"
echo ""
echo "1. Ouvrez n8n: $N8N_URL"
echo "   - Login: $N8N_USER"
echo "   - Password: $N8N_PASSWORD"
echo ""
echo "2. Cliquez sur '...' puis 'Import from File'"
echo ""
echo "3. Importez ces fichiers:"
echo "   - $WORKFLOWS_DIR/rss_processor.json"
echo "   - $WORKFLOWS_DIR/cleanup.json"
echo "   - $WORKFLOWS_DIR/notifications.json"
echo ""
echo "4. IMPORTANT: Configurez la variable d'environnement"
echo "   - Allez dans Settings > Variables"
echo "   - Ajoutez: SUPABASE_SERVICE_KEY"
echo "   - Valeur: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1sb2NhbCIsInJvbGUiOiJzZXJ2aWNlX3JvbGUiLCJleHAiOjE5ODM4MTI5OTZ9.CvGPVcSrdWNqg71tF_g4YKevVDnN4F2WdoXh3ce0T7k"
echo ""
echo "5. Activez chaque workflow apres l'import"
echo ""
echo "================================================"
echo ""

# Ouvrir n8n dans le navigateur (si possible)
echo "[3/4] Ouverture de n8n dans le navigateur..."
if command -v xdg-open &> /dev/null; then
    xdg-open "$N8N_URL" 2>/dev/null || true
elif command -v open &> /dev/null; then
    open "$N8N_URL" 2>/dev/null || true
else
    echo -e "${YELLOW}[INFO]${NC} Ouvrez manuellement: $N8N_URL"
fi

echo ""
echo "[4/4] Verification du modele Ollama..."
if docker exec kairos-ollama ollama list 2>/dev/null | grep -qi "gemma"; then
    echo -e "${GREEN}[OK]${NC} Modele gemma3:4b present"
else
    echo -e "${YELLOW}[INFO]${NC} Le modele gemma3:4b n'est pas installe."
    echo "       Telechargement en cours (environ 3 GB)..."
    docker exec kairos-ollama ollama pull gemma3:4b
    echo -e "${GREEN}[OK]${NC} Modele telecharge"
fi

echo ""
echo "================================================"
echo "   Configuration terminee!"
echo "================================================"
echo ""
echo "N'oubliez pas d'activer les workflows dans n8n."
echo ""
