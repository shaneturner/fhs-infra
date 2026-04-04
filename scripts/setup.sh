#!/bin/bash
set -e

echo "Starting FHS Infrastructure Setup..."

# 1. Initialize and update all submodules
echo "Initializing submodules..."
git submodule update --init --recursive

# 2. Ensure Git LFS is installed and active
echo "Ensuring Git LFS is active..."
git lfs install

# 3. Pull LFS assets for the main repo (if any)
echo "Pulling LFS assets for main repository..."
git lfs pull

# 4. Pull LFS assets for all submodules recursively
echo "Pulling LFS assets for all submodules..."
git submodule foreach --recursive 'git lfs pull'

# 5. Success
echo "Setup complete! All submodules and LFS assets are ready."
