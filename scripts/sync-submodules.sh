#!/bin/bash
# scripts/sync-submodules.sh
# Updates all submodules to their latest tracked branch versions and commits the changes to the root.

set -e

echo "Updating all submodules to their latest branch versions..."
git submodule update --remote --merge

echo "Staging changes..."
git add apps/

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "Everything is already up to date."
else
    echo "Committing submodule updates..."
    git commit -m "chore: sync submodules to latest branch versions"
    echo "Pushing to root remote..."
    git push
    echo "Sync complete!"
fi
