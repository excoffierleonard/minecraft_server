# Minecraft Fabric Server Docker

![Minecraft Logo](https://static.wikia.nocookie.net/logopedia/images/0/0f/Minecraft_Bedrock_2023.svg/revision/latest/scale-to-width-down/250?cb=20230920113315)

This Docker image provides a simple and efficient way to run a Minecraft server using the Fabric mod loader. It automatically downloads the latest stable version of Minecraft and Fabric, making it easy to keep your server up-to-date.

## Prerequisites

- Docker
- Docker Compose (Necessary for Quick Start)

## Quick Start

```bash
curl -o compose.yaml https://git.jisoonet.com/el/minecraftserver/raw/branch/main/compose.yaml && docker compose up -d
```

## Features

- 🚀 Automatically downloads the latest stable Minecraft Fabric Server version
- 🔧 Easy configuration through environment variables
- 💾 Persistent data storage using Docker volumes
- 🔄 Auto-restarts on crashes
- 📜 Pre-accepted EULA for convenience

## Run

To get started with your Minecraft Fabric server, run the following command:

```bash
docker run -d \
  -p 25565:25565 \
  -e JAVA_XMS=2048M \
  -e JAVA_XMX=2048M \
  -v /path/to/minecraft/data:/minecraftserver/appdata \
  your-docker-image-name
```

Replace `/path/to/minecraft/data` with the path where you want to store your Minecraft server data.

## Environment Variables

- `JAVA_XMS`: Minimum memory allocation pool for Java (default: 2048M)
- `JAVA_XMX`: Maximum memory allocation pool for Java (default: 2048M)

## Volume

The container exposes a volume at `/minecraftserver/appdata`. This directory contains all of the server's data, including world files, configuration, and logs.

## Ports

The container exposes port 25565, which is the default port for Minecraft servers.

## Customization

To customize your server, you can modify the files in the mounted volume. Some key files include:

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
