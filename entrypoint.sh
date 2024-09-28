#!/bin/bash

cd ./appdata

SERVER_FILE_NAME="server-fabric.jar"

get_latest_minecraft_version() {
    curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][0].version'
}

get_latest_loader_version() {
    curl -s https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION | jq -r '[.[] | select(.loader.stable == true) | .loader.version][0]'
}

download_server() {
    curl -o $SERVER_FILE_NAME https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$LOADER_VERSION/$INSTALLER_VERSION/server/jar
}

if [ ! -f "$SERVER_FILE_NAME" ]; then
    echo "Server file not found. Downloading..."

    MINECRAFT_VERSION=$(get_latest_minecraft_version)
    LOADER_VERSION=$(get_latest_loader_version)
    INSTALLER_VERSION="1.0.1"
    
    download_server
else
    echo "Server file already exists. Skipping download."
fi

exec java -Xms$JAVA_XMS -Xmx$JAVA_XMX -jar $SERVER_FILE_NAME nogui