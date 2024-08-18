#!/bin/bash

STEAM_DEPOT_SCRIPT="$1"
BUILD_DESCRIPTION="$2"

STEAMCMD_PATH="$HOME/Steamworks/sdk/tools/ContentBuilder/builder_linux/steamcmd.sh"


# Check that there STEAM_DEPOT_SCRIPT points to an existing *.vdf file
if [[ "$STEAM_DEPOT_SCRIPT" != *.vdf ]]; then
    echo "Error: path '$STEAM_DEPOT_SCRIPT' does not point to a .vdf file."
    exit 1
fi

if [[ ! -f "$STEAM_DEPOT_SCRIPT" ]]; then
    echo "Error: file '$STEAM_DEPOT_SCRIPT' does not exist."
    exit 1
fi


# Replace [BUILD_DESCRIPTION] in the .vdf file with the value of $BUILD_DESCRIPTION
sed -i "s/\[BUILD_DESCRIPTION\]/$BUILD_DESCRIPTION/" "$STEAM_DEPOT_SCRIPT"


# Zip the directory
#DIRECTORY_TO_ZIP="./my_directory"
#ZIP_FILE_NAME="my_archive.zip"
# Check if the directory exists
#if [ ! -d "$DIRECTORY_TO_ZIP" ]; then
    #echo "Directory $DIRECTORY_TO_ZIP does not exist."
    #exit 1
#fi
#zip -r "$TEMP_PATH/$ZIP_FILE_NAME" "$DIRECTORY_TO_ZIP"

# Check if zip was successful
#if [ $? -eq 0 ]; then
    #echo "Successfully created $ZIP_FILE_NAME."
#else
    #echo "Failed to create $ZIP_FILE_NAME."
    #exit 1
#fi

### Get credentials

# Prompt for Steam username
echo "Enter your Steam username:"
read -r STEAM_USERNAME

# Prompt for the password securely
echo "Enter your Steam password:"
read -rs STEAM_PASSWORD

### Publish to Steam
# Login to Steam and upload the build
"$STEAMCMD_PATH" +login "$STEAM_USERNAME" "$STEAM_PASSWORD" +run_app_build "$STEAM_DEPOT_SCRIPT" +quit

# Check if the Steam upload was successful
if [ $? -eq 0 ]; then
    echo "Successfully uploaded to Steam."
else
    echo "Failed to upload to Steam."
    exit 1
fi


# Clear the password variable for security
unset STEAM_PASSWORD
