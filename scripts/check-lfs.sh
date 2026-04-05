#!/bin/bash
# scripts/check-lfs.sh
# Verifies that Git LFS assets are correctly pulled for the root and all submodules.

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Checking Git LFS status..."

check_lfs() {
    local dir=$1
    echo -n "Checking $dir... "
    
    # Run git lfs ls-files and check for the presence of the '-' or '*' indicator.
    # '*' means the file is present in the working tree (pointer is replaced with content).
    # '-' means the file is missing (only the pointer is present).
    local missing_files=$(git -C "$dir" lfs ls-files | grep "^-" | wc -l)

    if [ "$missing_files" -gt 0 ]; then
        echo -e "${RED}FAILED${NC} ($missing_files files missing)"
        return 1
    else
        echo -e "${GREEN}PASSED${NC}"
        return 0
    fi
}

exit_code=0

# 1. Check Root
check_lfs "." || exit_code=1

# 2. Check Submodules
git submodule foreach --quiet --recursive '
    echo -n "Checking $displaypath... "
    missing_files=$(git lfs ls-files | grep "^-" | wc -l)
    if [ "$missing_files" -gt 0 ]; then
        echo -e "\033[0;31mFAILED\033[0m ($missing_files files missing)"
        exit 1
    else
        echo -e "\033[0;32mPASSED\033[0m"
        exit 0
    fi
' || exit_code=1

if [ "$exit_code" -eq 0 ]; then
    echo -e "\n${GREEN}Success: All LFS assets are correctly pulled.${NC}"
else
    echo -e "\n${RED}Error: Some LFS assets are missing. Run ./scripts/setup.sh to pull them.${NC}"
fi

exit $exit_code
