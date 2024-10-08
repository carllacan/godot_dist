#!/bin/bash


#OUTPUT_PATH="$HOME/Godot/dist"


# The first argument is the path where the .godot file is to be found
PROJECT_PATH="$1"
# The second argument is the path where the project will be cloned to before being built (a directory will be created in this path)
TEMP_PATH="$2" #"/tmp"
# The third argument is the commit that will be cloned and built
TARGET_COMMIT="$3"


### Manage project path argument

# Convert PROJECT_PATH to an absolute path if it is not already absolute
if [[ "$PROJECT_PATH" != /* ]]; then
    PROJECT_PATH="$(pwd)/$PROJECT_PATH"
fi

# Check that there is a *.godot file in PROJECT_PATH
if ! ls "$PROJECT_PATH"/*.godot 1> /dev/null 2>&1; then
    echo "Error: No .godot file found in $PROJECT_PATH."
    exit 1
fi


### Get configuration from JSON file

CONFIG_FILE_DIR="$PROJECT_PATH/dist"
CONFIG_FILE_PATH="$CONFIG_FILE_DIR/godot_dist.json"

## Path to repo

# Check if godot_dist.json exists and read repo_path from it
REPO_REL_PATH=""
if [[ -z "$REPO_REL_PATH" && -f "$CONFIG_FILE_PATH" ]]; then
    REPO_REL_PATH=$(grep -oP '(?<="repo_path": ")[^"]*' "$CONFIG_FILE_PATH")
fi

# If REPO_REL_PATH is still empty, set it to "." by default
REPO_REL_PATH="${REPO_REL_PATH:-..}"

# Create REPO_PATH by concatenating CONFIG_FILE_PATH and REPO_REL_PATH
REPO_PATH="$CONFIG_FILE_DIR/$REPO_REL_PATH"

# Check that there is a git repo in REPO_PATH
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: No git repository found in ''$REPO_PATH'"
    exit 1
fi

# Check that there is at least a commit in that repo
if ! git -C "$REPO_PATH" rev-parse HEAD >/dev/null 2>&1; then
    echo "Error: No commits found in the git repository at $REPO_PATH."
    exit 1
fi

# Create a variable called PROJECT_REL_PATH, which is a relative path from REPO_PATH to PROJECT_PATH
# TODO: find a way to avoid this?
PROJECT_REL_PATH=$(realpath --relative-to="$REPO_PATH" "$PROJECT_PATH")

# Obtain the project name from the *.godot file in PROJECT_PATH
PROJECT_NAME=$(grep -oP '(?<=config/name=")[^"]*' "$PROJECT_PATH"/*.godot)

# Create a variable SAFE_PROJECT_NAME safe for use in paths
SAFE_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr -cd '[:alnum:]_-')

# Read file godot_dist.json at PROJECT_PATH and load parameter "godot_path" to variable GODOT_PATH
if [ -f "$CONFIG_FILE_PATH" ]; then
    GODOT_PATH=$(grep -oP '(?<="godot_path": ")[^"]*' "$CONFIG_FILE_PATH")
else
    GODOT_PATH="godot"
fi


# Create temporary directory if it doesn't already exist
DIST_DIR="$TEMP_PATH/$TARGET_COMMIT"
mkdir -p "$DIST_DIR"

# Go to the temporary directory, create directory SAFE_PROJECT_NAME, delete it if it already exists
if [[ -d "$DIST_DIR" ]]; then
    rm -rf "$DIST_DIR"
fi
mkdir -p "$DIST_DIR"

### Clone the latest commit from the repo in folder PROJECT_PATH to temporary directory

#git clone --depth 1 "$REPO_PATH" "$DIST_DIR" # old version that gets the last commit

# Clone the target commit
echo "###"
echo "Cloning commit '$TARGET_COMMIT' from repot at '$REPO_PATH'"
echo "###"
git clone --no-checkout "$REPO_PATH" "$DIST_DIR"
cd "$DIST_DIR"
git fetch --depth 1 origin "$TARGET_COMMIT" #--tags might be necessary here?
git checkout "$TARGET_COMMIT"

# Define a variable called CLONED_PROJECT_PATH
CLONED_PROJECT_PATH="$DIST_DIR/$PROJECT_REL_PATH"

# Check that a .godot file exists at CLONED_PROJECT_PATH
if ! ls "$CLONED_PROJECT_PATH"/*.godot 1> /dev/null 2>&1; then
    echo "Error: No .godot file found in $CLONED_PROJECT_PATH."
    exit 1
fi

# Create or edit a text file named version_info.json and set the "version" to the commit hash
COMMIT_HASH=$(git -C "$REPO_PATH" rev-parse HEAD)
echo "{\"commit\": \"$COMMIT_HASH\"}" > "$CLONED_PROJECT_PATH/dist/version_info.json"

### Export all versions

# Print building project information
echo "###"
echo "Building project $PROJECT_NAME from $CLONED_PROJECT_PATH using $GODOT_PATH"
echo "###"

echo "Making sure resources are imported"
#$GODOT_PATH --path "$CLONED_PROJECT_PATH" --import --quit --verbose

# Export Linux full version
echo "###"
echo "Exporting full Linux version"
echo "###"

"$GODOT_PATH" --headless --no-window --path "$CLONED_PROJECT_PATH" --export "Linux"  --quit

# Export Linux demo version
echo "###"
echo "Exporting Demo Linux version"
echo "###"

"$GODOT_PATH" --headless --no-window --path "$CLONED_PROJECT_PATH" --export "Linux Demo"  --quit

# Export Windows full version
echo "###"
echo "Exporting full Windows version"
echo "###"

"$GODOT_PATH" --headless --no-window --path "$CLONED_PROJECT_PATH" --export "Windows"  --quit

# Export Windows Demo version
echo "###"
echo "Exporting Demo Windows version"
echo "###"

"$GODOT_PATH" --headless --no-window --path "$CLONED_PROJECT_PATH" --export "Windows Demo"  --quit
