#!/bin/bash

# Check if the repo path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/repo"
    exit 1
fi

# Assign the first argument to REPO_PATH
REPO_PATH="$1"

# Check if the given path is a valid git repository
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: $REPO_PATH is not a valid git repository."
    exit 1
fi

# Navigate to the repository path
cd "$REPO_PATH" || exit

# Get the hash of the last commit
LAST_COMMIT_HASH=$(git rev-parse HEAD)

# Output the last commit hash
echo "$LAST_COMMIT_HASH"
