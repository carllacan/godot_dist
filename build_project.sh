#!/bin/bash

OUTPUT_PATH = "$HOME/Godot/dist"

# Temporary path where project will be cloned to before being built
TEMP_PATH="/tmp"

# The first argument is the path where the .godot file is to be found
PROJECT_PATH="$1"

# Convert PROJECT_PATH to an absolute path if it is not already absolute
if [[ "$PROJECT_PATH" != /* ]]; then
    PROJECT_PATH="$(pwd)/$PROJECT_PATH"
fi

# Check that there is a *.godot file in PROJECT_PATH
if ! ls "$PROJECT_PATH"/*.godot 1> /dev/null 2>&1; then
    echo "Error: No .godot file found in $PROJECT_PATH."
    exit 1
fi

# The second optional argument is the path where the git repo is to be found, relative to PROJECT_PATH
REPO_REL_PATH="${2:-}"

# If REPO_REL_PATH is not provided, check if godot_dist.json exists and read repo_path from it
if [[ -z "$REPO_REL_PATH" && -f "$PROJECT_PATH/godot_dist.json" ]]; then
    REPO_REL_PATH=$(grep -oP '(?<="repo_path": ")[^"]*' "$PROJECT_PATH/godot_dist.json")
fi

# If REPO_REL_PATH is still empty, set it to ".." by default
REPO_REL_PATH="${REPO_REL_PATH:-..}"

# Create REPO_PATH by concatenating PROJECT_PATH and REPO_REL_PATH
REPO_PATH="$PROJECT_PATH/$REPO_REL_PATH"

# Check that there is a git repo in REPO_PATH
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: No git repository found in $REPO_PATH."
    exit 1
fi

# Check that there is at least a commit in that repo
if ! git -C "$REPO_PATH" rev-parse HEAD >/dev/null 2>&1; then
    echo "Error: No commits found in the git repository at $REPO_PATH."
    exit 1
fi

# Create a variable called PROJECT_REL_PATH, which is a relative path from REPO_PATH to PROJECT_PATH
PROJECT_REL_PATH=$(realpath --relative-to="$REPO_PATH" "$PROJECT_PATH")

# Obtain the project name from the *.godot file in PROJECT_PATH
PROJECT_NAME=$(grep -oP '(?<=config/name=")[^"]*' "$PROJECT_PATH"/*.godot)

# Create a variable SAFE_PROJECT_NAME safe for use in paths
SAFE_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr -cd '[:alnum:]_-')

# Read file godot_dist.json at PROJECT_PATH and load parameter "godot_path" to variable GODOT_PATH
if [ -f "$PROJECT_PATH/godot_dist.json" ]; then
    GODOT_PATH=$(grep -oP '(?<="godot_path": ")[^"]*' "$PROJECT_PATH/godot_dist.json")
else
    GODOT_PATH="godot"
fi

# Print building project information
echo "Building project $PROJECT_NAME from $PROJECT_PATH using $GODOT_PATH"

# Create directory TEMP_PATH/godot_dist if it doesn't already exist
mkdir -p "$TEMP_PATH/godot_dist"

# Go to TEMP_PATH/godot_dist, create directory SAFE_PROJECT_NAME, delete it if it already exists
DIST_DIR="$TEMP_PATH/godot_dist/$SAFE_PROJECT_NAME"
if [[ -d "$DIST_DIR" ]]; then
    rm -rf "$DIST_DIR"
fi
mkdir -p "$DIST_DIR"

# Clone the latest commit from the repo in folder PROJECT_PATH to folder TEMP_PATH/godot_dist/SAFE_PROJECT_NAME
git clone --depth 1 "$REPO_PATH" "$DIST_DIR"

# Define a variable called CLONED_PROJECT_PATH
CLONED_PROJECT_PATH="$DIST_DIR/$PROJECT_REL_PATH"

# Check that a .godot file exists at CLONED_PROJECT_PATH
if ! ls "$CLONED_PROJECT_PATH"/*.godot 1> /dev/null 2>&1; then
    echo "Error: No .godot file found in $CLONED_PROJECT_PATH."
    exit 1
fi

# Create or edit a text file named version_info.json and set the "version" to the commit hash
COMMIT_HASH=$(git -C "$REPO_PATH" rev-parse HEAD)
echo "{\"version\": \"$COMMIT_HASH\"}" > "$CLONED_PROJECT_PATH/version_info.json"

# Run the app at GODOT_PATH passing CLONED_PROJECT_PATH as the first parameter, with options --export-release, --headless

WINDOWS_PATH = "$OUTPUT_PATH/SAFE_PROJECT_NAME/$COMMIT_HASH/windows/full"
WINDOWS_DEMO_PATH = "$OUTPUT_PATH/SAFE_PROJECT_NAME/$COMMIT_HASH/windows/demo"

mkdir -p "$WINDOWS_PATH"
mkdir -p "$WINDOWS_DEMO_PATH"

"$GODOT_PATH" --path "$CLONED_PROJECT_PATH" --headless --export-release "Windows (full)" "$WINDOWS_PATH"
"$GODOT_PATH" --path "$CLONED_PROJECT_PATH" --headless --export-release "Windows (demo)" "$WINDOWS_DEMO_PATH"

echo "Build completed successfully."
