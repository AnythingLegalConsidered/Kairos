#!/bin/bash
# =============================================================================
# KAIROS - Setup Script
# =============================================================================
# This script initializes the Kairos development environment
# Usage: ./scripts/setup.sh
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                     KAIROS - Setup                            ║"
echo "║               Plateforme de Veille Intelligente               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# -----------------------------------------------------------------------------
# Check prerequisites
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Docker is installed${NC}"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Docker Compose is installed${NC}"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running. Please start Docker.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Docker daemon is running${NC}"

# -----------------------------------------------------------------------------
# Create directories
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2/6] Creating directories...${NC}"

mkdir -p "$PROJECT_ROOT/supabase/migrations"
mkdir -p "$PROJECT_ROOT/n8n/workflows"
mkdir -p "$PROJECT_ROOT/docker/nginx"

echo -e "${GREEN}  ✓ Directories created${NC}"

# -----------------------------------------------------------------------------
# Setup environment file
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3/6] Setting up environment...${NC}"

if [ ! -f "$PROJECT_ROOT/docker/.env" ]; then
    if [ -f "$PROJECT_ROOT/docker/.env.example" ]; then
        cp "$PROJECT_ROOT/docker/.env.example" "$PROJECT_ROOT/docker/.env"
        echo -e "${GREEN}  ✓ Created .env from .env.example${NC}"
        echo -e "${YELLOW}  ! Please review and update docker/.env with your settings${NC}"
    else
        echo -e "${RED}  Error: .env.example not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}  ✓ .env file already exists${NC}"
fi

# -----------------------------------------------------------------------------
# Pull Docker images
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[4/6] Pulling Docker images (this may take a while)...${NC}"

cd "$PROJECT_ROOT/docker"
docker-compose pull

echo -e "${GREEN}  ✓ Docker images pulled${NC}"

# -----------------------------------------------------------------------------
# Start services
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[5/6] Starting services...${NC}"

docker-compose up -d

echo -e "${GREEN}  ✓ Services started${NC}"

# -----------------------------------------------------------------------------
# Download Ollama model
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[6/6] Downloading Gemma 3 model for Ollama...${NC}"

# Wait for Ollama to be ready
echo "  Waiting for Ollama to start..."
sleep 10

# Pull the gemma3:4b model
docker exec kairos-ollama ollama pull gemma3:4b || {
    echo -e "${YELLOW}  ! Could not download model now. Run later:${NC}"
    echo -e "${YELLOW}    docker exec kairos-ollama ollama pull gemma3:4b${NC}"
}

echo -e "${GREEN}  ✓ Gemma 3:4b model downloaded${NC}"

# -----------------------------------------------------------------------------
# Final summary
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                   Setup Complete!                             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Services available at:"
echo -e "  ${BLUE}Frontend:${NC}      http://localhost:3000"
echo -e "  ${BLUE}Supabase API:${NC}  http://localhost:8000"
echo -e "  ${BLUE}n8n:${NC}           http://localhost:5678 (admin/kairos2024)"
echo -e "  ${BLUE}Ollama:${NC}        http://localhost:11434"
echo ""
echo "Useful commands:"
echo -e "  ${YELLOW}./scripts/start.sh${NC}  - Start all services"
echo -e "  ${YELLOW}./scripts/stop.sh${NC}   - Stop all services"
echo -e "  ${YELLOW}./scripts/reset.sh${NC}  - Reset database"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review docker/.env and update passwords"
echo "  2. Access n8n at http://localhost:5678"
echo "  3. Import workflows from n8n/workflows/"
echo ""
