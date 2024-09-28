# Minecraft Server Project

This project sets up a Minecraft server using Docker with the Fabric mod loader. It automatically downloads the latest stable version of Minecraft and Fabric loader when starting up.

## Requirements

- Docker
- Docker Compose (Necessary for Quick Start)

## Quick Start

1. Clone this repository:
   ```
   git clone https://your-repository-url.git
   cd minecraft-server-project
   ```

2. Create a `.env` file in the project root and set your desired environment variables (see Environment Variables section below).

3. Run the server:
   ```
   docker-compose up -d
   ```

## Building the Image Locally

To build the Docker image locally:

1. Navigate to the project directory.
2. Run the following command:
   ```
   docker build -t minecraft-server .
   ```

## Environment Variables

Set these variables in your `.env` file or pass them directly to Docker Compose:

- `JAVA_XMS`: Initial memory allocation pool for Java (default: 1024M)
- `JAVA_XMX`: Maximum memory allocation pool for Java (default: 1024M)
- `SERVER_PORT`: The port for the Minecraft server (default: 25565)
- `RCON_PORT`: The port for RCON (Remote Console) access (required, no default)

Example `.env` file:
```
JAVA_XMS=2048M
JAVA_XMX=4096M
SERVER_PORT=25565
RCON_PORT=25575
```

## Docker Compose Example

Here's an example `compose.yaml` file:

```yaml
services:
  minecraftserver:
    image: git.jisoonet.com/el/minecraftserver
    container_name: minecraftserver
    environment:
      JAVA_XMS: ${JAVA_XMS:-1024M}
      JAVA_XMX: ${JAVA_XMX:-1024M}
    ports:
      - "${SERVER_PORT:-25565}:25565"
      - ${RCON_PORT}:25575
    volumes:
      - minecraftserver:/minecraftserver/appdata
    networks:
      - minecraftserver

volumes:
  minecraftserver:
    name: minecraftserver

networks:
  minecraftserver:
    name: minecraftserver
```

## Usage

To start the server:
```
docker-compose up -d
```

To stop the server:
```
docker-compose down
```

To view logs:
```
docker-compose logs -f
```

## Customization

- The server files are stored in a Docker volume named `minecraftserver`.
- To access the server console, use the RCON port specified in your configuration.
- Modify the `entrypoint.sh` script to customize server startup behavior.

## Contributing

Feel free to open issues or submit pull requests for any improvements or bug fixes.

## License

[Specify your license here]