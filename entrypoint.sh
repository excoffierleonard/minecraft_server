#!/bin/bash

cd ./appdata

SERVER_FILE_NAME="server-fabric.jar"

if [ ! -f "$SERVER_FILE_NAME" ]; then
    echo "Jar file not found. Downloading..."
    download_server()
else
    echo "Jar file already exists. Skipping download."
fi


get_latest_minecraft_version() {
    curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][0].version'
}

get_latest_loader_version(){
    curl -s https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION | jq -r '[.[] | select(.loader.stable == true) | .loader.version][0]'
}

$MINECRAFT_VERSION = get_latest_minecraft_version()
$LOADER_VERSION = get_latest_loader_version()
$INSTALLER_VERSION = "1.0.1"

download_server() {
    curl -o $SERVER_FILE_NAME https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$LOADER_VERSION/$INSTALLER_VERSION/server/jar
}

exec java -Xmx$JAVA_XMX -Xms$JAVA_XMS -jar $JAR_FILE nogui