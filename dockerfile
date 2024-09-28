FROM openjdk:24-slim-bullseye

WORKDIR /minecraftserver

ENV JAVA_XMX=1024M
ENV JAVA_XMS=1024M 
ENV SERVER_NAME=server.jar

RUN apt update && apt install -y curl jq

RUN mkdir appdata

RUN echo "eula=true" > appdata/eula.txt

COPY entrypoint.sh .

CMD ["./entrypoint.sh"]