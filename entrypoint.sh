#!/bin/bash

set -e

# Ensure that required environment variables are set
check_env_vars() {
    : ${JAVA_XMS:?"Environment variable JAVA_XMS is required but not set"}
    : ${JAVA_XMX:?"Environment variable JAVA_XMX is required but not set"}
    : ${MINECRAFT_VERSION:?"Environment variable MINECRAFT_VERSION is required but not set"}
}

# Display current environment variables
show_env_info() {
    echo "JAVA_XMS: $JAVA_XMS"
    echo "JAVA_XMX: $JAVA_XMX"
    echo "MINECRAFT_VERSION: $MINECRAFT_VERSION"
}

# Resolve the required Minecraft version
resolve_minecraft_version() {
    MINECRAFT_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][0].version')
}

# Get the Fabric loader version for the specific Minecraft version
fetch_loader_version() {
    LOADER_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION | jq -r '[.[] | select(.loader.stable == true) | .loader.version][0]')
    if [ -z "$LOADER_VERSION" ] || [ "$LOADER_VERSION" = "null" ]; then
        echo "Error: Loader version is null or empty for Minecraft version $MINECRAFT_VERSION."
        exit 1
    fi
}

# Download the Minecraft server jar if missing
download_server() {
    if [ "$MINECRAFT_VERSION" = "latest" ]; then
        resolve_minecraft_version
    fi
    fetch_loader_version

    INSTALLER_VERSION="1.0.1"
    SERVER_FILE_NAME="server-$MINECRAFT_VERSION-fabric.jar"

    echo "Downloading Minecraft version $MINECRAFT_VERSION with Fabric loader $LOADER_VERSION and Installer $INSTALLER_VERSION to $SERVER_FILE_NAME..."
    curl -s -o "$SERVER_FILE_NAME" "https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$LOADER_VERSION/$INSTALLER_VERSION/server/jar"
}

# Check and download server jar if necessary
verify_or_download_server() {
    local server_files=(server-*.jar)
    if [ ! -f "${server_files[0]}" ]; then
        echo "Server file not found. Downloading..."
        download_server
    else
        SERVER_FILE_NAME="${server_files[0]}"
        echo "Server file found: $SERVER_FILE_NAME. Skipping download."
    fi
}

# Start the Minecraft server
start_server() {
    echo "Starting Minecraft server..."
    exec java -Xms"$JAVA_XMS" -Xmx"$JAVA_XMX" -jar "$SERVER_FILE_NAME" nogui
}

# Main process
main() {
    check_env_vars
    show_env_info
    cd ./appdata
    verify_or_download_server
    start_server
}

# Execute main function
main