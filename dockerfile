FROM openjdk:24-slim-bullseye

ENV JAVA_XMS=2048M

ENV JAVA_XMX=2048M

WORKDIR /minecraftserver

RUN apt update && apt install -y curl jq

RUN mkdir appdata

RUN echo "eula=true" > appdata/eula.txt

VOLUME /minecraftserver/appdata

EXPOSE 25565

COPY entrypoint.sh .

CMD ["./entrypoint.sh"]