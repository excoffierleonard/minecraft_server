FROM openjdk:24-slim-bookworm

ENV JAVA_XMS=1024M
ENV JAVA_XMX=1024M
ENV MINECRAFT_VERSION=latest

WORKDIR /minecraft_server

RUN apt update && apt install -y curl jq file unzip

RUN useradd -m minecraft_user

RUN mkdir appdata && \
    chown minecraft_user:minecraft_user /minecraft_server/appdata && \
    chmod 700 /minecraft_server/appdata

RUN echo "eula=true" > appdata/eula.txt && \
    chown minecraft_user:minecraft_user /minecraft_server/appdata/eula.txt

VOLUME /minecraft_server/appdata

EXPOSE 25565
EXPOSE 25575

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

USER minecraft_user

CMD ["./entrypoint.sh"]
