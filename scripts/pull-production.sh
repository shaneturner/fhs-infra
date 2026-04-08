#!/bin/bash
# scripts/pull-production.sh
# Synchronizes the production environment from the root repository.

set -e

echo "Updating root repository..."
git pull origin main

echo "Initializing and updating submodules..."
git submodule update --init --recursive

echo "Git synchronization complete!"
