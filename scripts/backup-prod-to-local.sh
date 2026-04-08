#!/bin/bash
# scripts/backup-prod-to-local.sh
# Pulls the production database and user-uploaded assets to the local machine for Git LFS backup.

set -e

# --- GUARD CLAUSE: Only run on local development host ---
# (Assumes your production host is named 'forresthill')
if [ "$(hostname)" == "forresthill" ]; then
    echo "ERROR: This script is for LOCAL development use only."
    echo "It pulls from production to your local machine."
    exit 1
fi

REMOTE_USER_HOST="forresthill"
REMOTE_PROJECT_ROOT="/home/deploy/fhs-infra"
SUBMODULE_PATH="apps/forresthill-postgres"
DB_CONTAINER="fhs-postgres"
DB_NAME="craft_pg"
DB_USER="craft"

echo "1/4: Dumping production database on the server..."
ssh "$REMOTE_USER_HOST" "docker exec $DB_CONTAINER pg_dump -U $DB_USER $DB_NAME > $REMOTE_PROJECT_ROOT/$SUBMODULE_PATH/forresthill.sql"

echo "2/4: Downloading database dump..."
scp "$REMOTE_USER_HOST:$REMOTE_PROJECT_ROOT/$SUBMODULE_PATH/forresthill.sql" "$SUBMODULE_PATH/forresthill.sql"

echo "3/4: Syncing user-uploaded images..."
rsync -avz --progress --exclude='_*' --exclude='temp_*' \
    "$REMOTE_USER_HOST:$REMOTE_PROJECT_ROOT/$SUBMODULE_PATH/web/images/" \
    "$SUBMODULE_PATH/web/images/"

echo "4/4: Cleaning up temporary dump on server..."
ssh "$REMOTE_USER_HOST" "rm $REMOTE_PROJECT_ROOT/$SUBMODULE_PATH/forresthill.sql"

echo "-------------------------------------------------------"
echo "Success! Production data is now synced to your local machine."
echo "You can now review the changes in '$SUBMODULE_PATH' and commit them to Git LFS."
echo "-------------------------------------------------------"
