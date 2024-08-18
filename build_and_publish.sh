

TARGET_PROJECT="$1"
TARGET_COMMIT="$(./get_last_commit.sh ~/Desktop/hexis)"

# Build the game
./build_project.sh "$TARGET_PROJECT" "/tmp"  "$TARGET_COMMIT"

VDF_FILES_DIR="/tmp/$TARGET_COMMIT/dist/steamworks_scripts/"

#./publish_to_steam.sh "/tmp/$TARGET_COMMIT/dist/steamworks_scripts/main_app/main_app_build.vdf" "commit $TARGET_COMMIT"
echo "Looking for .vdf files in '$VDF_FILES_DIR'"

# Loop over each .vdf file in the directory
for VDF_FILE in "$VDF_FILES_DIR"/*.vdf; do
    if [[ -f "$VDF_FILE" ]]; then
        echo "###"
        echo "Running Steampipe builder for file '$VDF_FILE'"
        echo "###"
        ./publish_to_steam.sh "$VDF_FILE" "commit $TARGET_COMMIT"
    fi
done
