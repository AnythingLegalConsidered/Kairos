#!/bin/bash
# =============================================================================
# KAIROS - Stop Script
# =============================================================================
# Stops all Kairos services
# Usage: ./scripts/stop.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${YELLOW}Stopping Kairos services...${NC}"

cd "$PROJECT_ROOT/docker"

docker-compose down

echo ""
echo -e "${GREEN}All services stopped.${NC}"
echo ""
