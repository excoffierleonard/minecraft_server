#!/bin/bash

cd ./appdata

JAR_FILE="server-fabric.jar"

if [ ! -f "$JAR_FILE" ]; then
    echo "Jar file not found. Downloading..."
    curl -o "$JAR_FILE" https://meta.fabricmc.net/v2/versions/loader/1.21.1/0.16.5/1.0.1/server/jar
else
    echo "Jar file already exists. Skipping download."
fi


get_latest_minecraft_version() {
    curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '[.[] | select(.stable == true)][0].version'
}

$MINECRAFT_VERSION = get_latest_minecraft_version()

get_latest_loader_version(){
    curl -s https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION | jq -r '[.[] | select(.loader.stable == true) | .loader.version][0]'
}

$LOADER_VERSION = get_latest_loader_version()

$INSTALLER_VERSION = "1.0.1"

download_server() {
    curl https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$LOADER_VERSION/$INSTALLER_VERSION/server/jar
}

exec java -Xmx$JAVA_XMX -Xms$JAVA_XMS -jar $JAR_FILE nogui