#!/bin/bash
# scripts/git-pull-recursive.sh
# Synchronizes the production environment from the root repository.

set -e

# --- GUARD CLAUSE: Only run on production server ---
if [ "$(hostname)" != "vultr" ]; then
    echo "ERROR: This script is for the PRODUCTION server only."
    echo "It pulls from GitHub to the production server."
    exit 1
fi

echo "Updating root repository..."
git pull origin main

echo "Initializing and updating submodules..."
# Syncing submodules recursively
git submodule update --init --recursive

echo "Git synchronization complete!"
