#!/bin/bash
# =============================================================================
# KAIROS - Reset Script
# =============================================================================
# Resets the database and all volumes (DESTRUCTIVE!)
# Usage: ./scripts/reset.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    WARNING - DESTRUCTIVE                      ║"
echo "║     This will delete ALL data including database!             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

read -p "Are you sure you want to reset everything? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}Reset cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Stopping all services...${NC}"

cd "$PROJECT_ROOT/docker"

# Stop and remove containers
docker-compose down

echo -e "${YELLOW}Removing volumes...${NC}"

# Remove volumes
docker-compose down -v

echo -e "${YELLOW}Removing orphan containers...${NC}"

# Remove any orphan containers
docker-compose down --remove-orphans

echo ""
echo -e "${GREEN}Reset complete!${NC}"
echo ""
echo "Run ${YELLOW}./scripts/setup.sh${NC} to reinitialize the environment."
echo ""
