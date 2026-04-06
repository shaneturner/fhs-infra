#!/bin/bash
set -e

# Resolve the absolute path of the project root (handling symlinks)
SCRIPT_PATH=$(readlink -f "$0")
PROJECT_ROOT=$(dirname "$(dirname "$SCRIPT_PATH")")

# Change to project root so relative paths in compose files work correctly
cd "$PROJECT_ROOT"

# Execute docker compose with both base and production override files
# All arguments passed to this script ($@) are forwarded to docker compose
docker compose -f docker-compose.yml -f docker-compose.prod.yml "$@"
