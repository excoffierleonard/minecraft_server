#!/bin/bash

cd ./appdata

JAR_FILE="fabric-server-launch.jar"

if [ ! -f "$JAR_FILE" ]; then
    echo "Jar file not found. Downloading..."
    curl -o "$JAR_FILE" https://meta.fabricmc.net/v2/versions/loader/1.21.1/0.16.5/1.0.1/server/jar
else
    echo "Jar file already exists. Skipping download."
fi

exec java -Xmx$JAVA_XMX -Xms$JAVA_XMS -jar $JAR_FILE nogui