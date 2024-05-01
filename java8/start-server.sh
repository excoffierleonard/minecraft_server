#!/bin/bash
cd ./server-data
exec java -Xmx$JAVA_XMX -Xms$JAVA_XMS -jar $SERVER_NAME nogui