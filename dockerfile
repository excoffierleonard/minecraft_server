FROM openjdk:24-slim-bookworm

ENV JAVA_XMS=1024M
ENV JAVA_XMX=1024M
ENV MINECRAFT_VERSION=latest

WORKDIR /minecraft_server

RUN apt update && apt install -y curl jq file unzip

RUN mkdir appdata
RUN echo "eula=true" > appdata/eula.txt

VOLUME /minecraft_server/appdata

EXPOSE 25565
EXPOSE 25575

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
