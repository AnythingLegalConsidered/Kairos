#!/bin/bash
# =============================================================================
# KAIROS - Start Script
# =============================================================================
# Starts all Kairos services
# Usage: ./scripts/start.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting Kairos services...${NC}"

cd "$PROJECT_ROOT/docker"

# Start all services
docker-compose up -d

echo ""
echo -e "${GREEN}All services started!${NC}"
echo ""
echo "Services:"
echo -e "  ${BLUE}Frontend:${NC}      http://localhost:3000"
echo -e "  ${BLUE}Supabase API:${NC}  http://localhost:8000"
echo -e "  ${BLUE}n8n:${NC}           http://localhost:5678"
echo -e "  ${BLUE}Ollama:${NC}        http://localhost:11434"
echo ""
