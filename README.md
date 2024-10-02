# Minecraft Fabric Server Docker

![Minecraft Logo](https://static.wikia.nocookie.net/logopedia/images/0/0f/Minecraft_Bedrock_2023.svg/revision/latest/scale-to-width-down/250?cb=20230920113315)

This Docker image provides a simple and efficient way to run a Minecraft server using the Fabric mod loader. It automatically downloads the latest stable version of Minecraft Fabric Server, making it easy to start and keep your server up-to-date.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Project Structure](#project-structure)
4. [Features](#features)
5. [Environment Variables](#environment-variables)
6. [Usage](#usage)
7. [Volume](#volume)
8. [Ports](#ports)
9. [Customization](#customization)
10. [Updating](#updating)
11. [Building the Image Locally](#building-the-image-locally)
12. [Contributing](#contributing)
13. [License](#license)
14. [Support](#support)

## Prerequisites

- Docker
- Docker Compose (Necessary for Quick Start)

## Quick Start

Execute the following command to download the `compose.yaml` file and start the Minecraft server using Docker Compose, useful if you don't want to think about the configuration.

```bash
curl -o compose.yaml https://git.jisoonet.com/el/minecraftserver/raw/branch/main/compose.yaml && docker compose up -d
```

## Project Structure

- `dockerfile`: Defines the Docker image, including dependencies and configuration.
- `entrypoint.sh`: Script to initialize and set up the environment for the minecraftserver.
- `compose.yaml`: Docker Compose file to define and manage the container.

## Features

- 🚀 Automatically downloads the latest stable Minecraft Fabric Server version
- 🔧 Easy configuration through environment variables
- 💾 Persistent data storage using Docker volumes
- 🔄 Auto-restarts on crashes
- 📜 Pre-accepted EULA for convenience

## Environment Variables

The following environment variables can be set either in a `.env` file, directly written in `compose.yaml`, or hardcoded in the `Run` command:

- `JAVA_XMS`: Minimum memory allocation pool for Java (default: 1024M)
- `JAVA_XMX`: Maximum memory allocation pool for Java (default: 1024M)
- `MINECRAFT_VERSION`: The version of Minecraft to download (default: latest, minimum: 1.14)
- `SERVER_PORT`: The port for the Minecraft server (default: 25565)
- `RCON_PORT`: The port for RCON (Remote Console) access (not required, is not forwarded by default)

## Usage

### Preferred Method: Docker Compose

1. **Create a `compose.yaml` File:**

Create a `compose.yaml` file with the following content, you can find a template in the repo [here](compose.yaml).

```yaml
services:
  minecraftserver:
    image: git.jisoonet.com/el/minecraftserver
    container_name: minecraftserver
    environment:
      JAVA_XMS: ${JAVA_XMS:-1024M}
      JAVA_XMX: ${JAVA_XMX:-1024M}
      MINECRAFT_VERSION: ${MINECRAFT_VERSION:-latest}
    ports:
      - "${SERVER_PORT:-25565}:25565"
      - "${RCON_PORT}:25575"
    volumes:
      - minecraftserver:/minecraftserver/appdata
    networks:
      - minecraftserver
    restart: unless-stopped

volumes:
  minecraftserver:
    name: minecraftserver

networks:
  minecraftserver:
    name: minecraftserver
```

Alternatively, you can download the [compose.yaml](compose.yaml) file directly from the repository:

```bash
curl -o compose.yaml https://git.jisoonet.com/el/minecraftserver/raw/branch/main/compose.yaml
```

2. **Create a `.env` File (Optional):**

Set up environment variables by creating a `.env` file in the same directory as `compose.yaml`. You can use the example below as a guideline:

```bash
JAVA_XMS=1024M
JAVA_XMX=1024M
MINECRAFT_VERSION=latest
SERVER_PORT=25565
RCON_PORT=25575
```

Alternatively, you can hardcode these values directly in [compose.yaml](compose.yaml).

3. **Launch the Service:**

Start the containers in detached mode with Docker Compose:

```bash
docker compose up -d
```

### Alternative Method: Docker Run

1. **Create a Docker Network:**

```bash
docker network create minecraftserver
```

2. **Execute the `Run` command:**

```bash
docker run \
  -d \
  --name minecraftserver \
  -e JAVA_XMS=1024M \
  -e JAVA_XMX=1024M \
  -e MINECRAFT_VERSION=latest \
  -p 25565:25565 \
  -v minecraftserver:/minecraftserver/appdata \
  --net=minecraftserver \
  git.jisoonet.com/el/minecraftserver
```

## Volume

The container exposes a docker volume at `/minecraftserver/appdata`. This directory contains all of the server's data, including world files, configuration, and logs.

## Ports

The container exposes port 25565 by default, which is the default port for Minecraft servers, you are free to change it if you have need multiple minecraft servers.
The container also exposes port 25575 for RCON (Remote Console) access, which is not required and is not forwarded by default.

## Customization

To customize your server, you can modify the files in the docker volume. Some key files include:

- `server.properties`: Main server configuration
- `ops.json`: List of server operators
- `whitelist.json`: List of whitelisted players (if whitelist is enabled)

## Updating

To update to the latest version of Minecraft and Fabric, simply remove the `server-*.jar` file from your data directory and restart the container. It will automatically download the latest versions.

> ⚠️ **Warning**: Updating may occasionally cause compatibility issues with existing mods or world saves. It's recommended to backup your data before updating.

## Building the Image Locally

```bash
git clone https://git.jisoonet.com/el/minecraftserver.git && \
cd minecraftserver && \
docker build -t minecraftserver .
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).

## Support

If you encounter any problems or have any questions, please open an issue in this repository.

Happy crafting! ⛏️🌳
