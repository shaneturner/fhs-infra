#!/bin/bash
# scripts/git-pull-recursive.sh
# Synchronizes the production environment from the root repository.

set -e

# --- GUARD CLAUSE: Only run on production server ---
if [ "$(hostname)" != "forresthill" ]; then
    echo "ERROR: This script is for the PRODUCTION server only."
    echo "It pulls from GitHub to the production server."
    exit 1
fi

echo "Updating root repository..."
git pull origin main

echo "Initializing and updating submodules (ignoring local untracked/dirty content)..."
# The --ignore-submodules=dirty flag ensures user uploads in web/images don't block the update
git submodule update --init --recursive --ignore-submodules=dirty

echo "Git synchronization complete!"
