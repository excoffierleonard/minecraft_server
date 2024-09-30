#!/bin/bash

# Validate memory size format (e.g., 512M, 1G, etc.)
validate_memory_size() {
    local mem_size=$1
    if ! [[ "$mem_size" =~ ^[0-9]+[GgMm]$ ]]; then
        echo "Error: Invalid memory size '$mem_size'. It must be in the format <number>[Gg|Mm] (e.g., 512M, 1G)."
        exit 1
    fi
}

# Display current environment variables
show_env_info() {
    echo "JAVA_XMS: $JAVA_XMS"
    echo "JAVA_XMX: $JAVA_XMX"
    echo "MINECRAFT_VERSION: $MINECRAFT_VERSION"
}

# Ensure that required environment variables are set
check_env_vars() {
    echo "Checking required environment variables..."
    : "${JAVA_XMS:?"Environment variable JAVA_XMS is required but not set"}"
    : "${JAVA_XMX:?"Environment variable JAVA_XMX is required but not set"}"
    : "${MINECRAFT_VERSION:?"Environment variable MINECRAFT_VERSION is required but not set"}"

    validate_memory_size "$JAVA_XMS"
    validate_memory_size "$JAVA_XMX"
    echo "All required environment variables are set."
    show_env_info
}

# Fetch the latest stable Minecraft version
fetch_latest_minecraft_version() {
    latest_version=$(curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][0].version')
    if [[ ! $latest_version =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: The retrieved version '$latest_version' is not a valid Minecraft version."
        exit 1
    fi
    MINECRAFT_VERSION=$latest_version
}

# Check if a specific Minecraft version is valid
validate_minecraft_version() {
    valid_versions=$(curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][].version')
    if ! echo "$valid_versions" | grep -Fxq "$MINECRAFT_VERSION"; then
        echo "Error: The provided Minecraft version '$MINECRAFT_VERSION' is not a valid or stable version."
        exit 1
    fi
}

# Get the Fabric loader version for the specific Minecraft version
fetch_loader_version() {
    LOADER_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/loader/"$MINECRAFT_VERSION" | jq -r '[.[] | select(.loader.stable == true) | .loader.version][0]')
    if [[ ! $LOADER_VERSION =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: The retrieved version '$LOADER_VERSION' is not a valid Loader version."
        exit 1
    fi
}

# Download the Minecraft server jar if missing
download_server() {
    echo "Attempting Minecraft server JAR file download..."
    if [ "$MINECRAFT_VERSION" = "latest" ]; then
        fetch_latest_minecraft_version
    else
        validate_minecraft_version
    fi
    fetch_loader_version

    INSTALLER_VERSION="1.0.1"
    SERVER_FILE_NAME="server-$MINECRAFT_VERSION-fabric.jar"

    echo "Downloading Minecraft version $MINECRAFT_VERSION with Fabric loader $LOADER_VERSION and Installer $INSTALLER_VERSION to $SERVER_FILE_NAME..."
    if ! curl -s -o "$SERVER_FILE_NAME" "https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$LOADER_VERSION/$INSTALLER_VERSION/server/jar"; then
        echo "Error: Failed to download the server JAR file."
        exit 1
    fi
    echo "Minecraft server JAR file downloaded successfully."
}

# Verify the existence of the server JAR file or download a new one
verify_or_download_server() {
    echo "Verifying the existence of the server JAR file..."
    local server_files=(server-*.jar)
    if [ ! -f "${server_files[0]}" ]; then
        echo "Server file not found."
        download_server
    else
        SERVER_FILE_NAME="${server_files[0]}"
        echo "Server file found: $SERVER_FILE_NAME. Skipping download."
    fi
}

# Verify the integrity of the downloaded JAR file
verify_jar_integrity() {
    echo "Verifying the integrity of the server JAR file..."
    if ! file "$SERVER_FILE_NAME" | grep -q "Zip archive data"; then
        echo "Error: The downloaded file is not a valid JAR file."
        download_server
    elif ! unzip -t "$SERVER_FILE_NAME" > /dev/null 2>&1; then
        echo "Error: The JAR file is corrupted or invalid."
        download_server
    else
        echo "JAR file integrity verified."
    fi
}

# Start the Minecraft server
start_server() {
    echo "Starting Minecraft server..."
    if ! java -version > /dev/null 2>&1; then
        echo "Error: Java is not installed or not in the system PATH."
        exit 1
    fi
    exec java -Xms"$JAVA_XMS" -Xmx"$JAVA_XMX" -jar "$SERVER_FILE_NAME" nogui
}

# Main function
main() {
    echo "Executing entrypoint script..."
    check_env_vars
    cd ./appdata || { echo "Error: Failed to change to ./appdata directory."; exit 1; }
    verify_or_download_server
    verify_jar_integrity
    start_server
}

# Execute the main function
main
