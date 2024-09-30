#!/bin/bash

# Ensure that required environment variables are set
check_env_vars() {
    : "${JAVA_XMS:?"Environment variable JAVA_XMS is required but not set"}"
    : "${JAVA_XMX:?"Environment variable JAVA_XMX is required but not set"}"
    : "${MINECRAFT_VERSION:?"Environment variable MINECRAFT_VERSION is required but not set"}"

    validate_memory_size "$JAVA_XMS"
    validate_memory_size "$JAVA_XMX"
}

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

# Fetch the latest stable Minecraft version
fetch_latest_minecraft_version() {
    latest_version=$(curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][0].version')
    if [[ ! $latest_version =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: The retrieved version '$latest_version' is not a valid Minecraft version."
        exit 1
    fi
    echo "Latest stable Minecraft version is $latest_version"
    MINECRAFT_VERSION=$latest_version
}

# Check if a specific Minecraft version is valid
validate_minecraft_version() {
    valid_versions=$(curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][].version')

    if ! echo "$valid_versions" | grep -Fxq "$MINECRAFT_VERSION"; then
        echo "Error: The provided Minecraft version '$MINECRAFT_VERSION' is not a valid or stable version."
        exit 1
    else
        echo "Validated Minecraft version: $MINECRAFT_VERSION"
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
}

# Verify the integrity of the downloaded JAR file
verify_jar_file() {
    local jar_file=$1
    if ! file "$jar_file" | grep -q "Zip archive data"; then
        echo "Error: The downloaded file is not a valid JAR file."
        return 1
    fi
    if ! unzip -t "$jar_file" > /dev/null 2>&1; then
        echo "Error: The JAR file is corrupted or invalid."
        return 1
    fi
    return 0
}

# Check and download the server jar file if necessary
verify_or_download_server() {
    local server_files=(server-*.jar)
    if [ ! -f "${server_files[0]}" ]; then
        echo "Server file not found. Downloading..."
        download_server
    else
        SERVER_FILE_NAME="${server_files[0]}"
        echo "Server file found: $SERVER_FILE_NAME. Skipping download."
    fi

    if ! verify_jar_file "$SERVER_FILE_NAME"; then
        echo "The existing server JAR file is invalid. Redownloading..."
        rm "$SERVER_FILE_NAME"
        download_server
        if ! verify_jar_file "$SERVER_FILE_NAME"; then
            echo "Error: Failed to download a valid server JAR file after retry."
            exit 1
        fi
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
    check_env_vars
    show_env_info
    cd ./appdata || { echo "Error: Failed to change to ./appdata directory."; exit 1; }
    verify_or_download_server
    start_server
}

# Execute the main function
main
