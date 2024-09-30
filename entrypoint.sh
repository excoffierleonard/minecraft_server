#!/bin/bash

set -e

# Exit if some environment variables are not set
: ${JAVA_XMS:?"Environment variable JAVA_XMS is required but not set"}
: ${JAVA_XMX:?"Environment variable JAVA_XMX is required but not set"}
: ${MINECRAFT_VERSION:?"Environment variable MINECRAFT_VERSION is required but not set"}

# Current Environment Variables
echo "JAVA_XMS: $JAVA_XMS"
echo "JAVA_XMX: $JAVA_XMX"
echo "MINECRAFT_VERSION: $MINECRAFT_VERSION"

cd ./appdata

SERVER_FILE_PATTERN="server-*.jar"

# Get the latest Minecraft version
get_latest_minecraft_version() {
    curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][0].version'
}

# Get the latest loader version for the specified Minecraft version
get_latest_loader_version() {
    curl -s https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION | jq -r '[.[] | select(.loader.stable == true) | .loader.version][0]'
}

# Download the server file
download_server() {
    if [ "$MINECRAFT_VERSION" = "latest" ]; then
        MINECRAFT_VERSION=$(get_latest_minecraft_version)
    fi

    LOADER_VERSION=$(get_latest_loader_version)
    if [ -z "$LOADER_VERSION" ] || [ "$LOADER_VERSION" = "null" ]; then
        echo "Error: Loader version is null or empty for Minecraft version $MINECRAFT_VERSION."
        exit 1
    fi

    INSTALLER_VERSION="1.0.1"
    
    SERVER_FILE_NAME="server-$MINECRAFT_VERSION-fabric.jar"

    echo "Downloading Minecraft version: $MINECRAFT_VERSION"
    curl -os $SERVER_FILE_NAME https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$LOADER_VERSION/$INSTALLER_VERSION/server/jar
}

# Check if the server file exists
if [ ! -f $SERVER_FILE_PATTERN ]; then
    echo "Server file not found. Downloading..."
    download_server
else
    echo "Server file already exists. Skipping download."
    SERVER_FILE_NAME=$(ls $SERVER_FILE_PATTERN | head -n 1)
fi

# Start the server
exec java -Xms$JAVA_XMS -Xmx$JAVA_XMX -jar $SERVER_FILE_NAME nogui
