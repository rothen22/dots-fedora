#!/bin/bash
# push.sh - Push commits to remote repository

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}✗ Not in a git repository${NC}"
    exit 1
fi

# Get current branch
branch=$(git rev-parse --abbrev-ref HEAD)

# Check if remote exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo -e "${RED}✗ No remote repository configured${NC}"
    exit 1
fi

# Check for unpushed commits
unpushed=$(git log origin/$branch..$branch --oneline 2>/dev/null | wc -l)

if [ "$unpushed" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No commits to push${NC}"
    exit 0
fi

echo -e "${YELLOW}Pushing $unpushed commit(s) to origin/$branch...${NC}"
git push origin "$branch"

echo -e "${GREEN}✓ Push successful!${NC}"
git log -1 --oneline
