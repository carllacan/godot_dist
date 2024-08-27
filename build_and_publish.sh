

TARGET_PROJECT="$1"
TARGET_REPO="$HOME/Projects/Hexis"

echo "Looking in path $TARGET_PROJECT"

TARGET_COMMIT="$(./get_last_commit.sh ~/Projects/hexis)"
TARGET_COMMIT_TAGS="$(./get_commit_tags.sh ~/Projects/hexis $TARGET_COMMIT)"

echo "Commit $TARGET_COMMIT with tag $TARGET_COMMIT_TAGS will be used"

# Build the game
./build_project.sh "$TARGET_PROJECT" "/tmp"  "$TARGET_COMMIT"

VDF_FILES_DIR="/tmp/$TARGET_COMMIT/dist/steamworks_scripts"

#./publish_to_steam.sh "/tmp/$TARGET_COMMIT/dist/steamworks_scripts/main_app/main_app_build.vdf" "commit $TARGET_COMMIT"
echo "Looking for .vdf files in '$VDF_FILES_DIR'"

# Loop over each .vdf file in the directory
for VDF_FILE in "$VDF_FILES_DIR"/*.vdf; do
    if [[ -f "$VDF_FILE" ]]; then
        echo "###"
        echo "Running Steampipe builder for file '$VDF_FILE'"
        echo "###"
        ./publish_to_steam.sh "$VDF_FILE" "$TARGET_COMMIT_TAGS ($TARGET_COMMIT)"
    fi
done
