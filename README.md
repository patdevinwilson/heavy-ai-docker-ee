# heavy-ai-docker-ee

# HeavyAI Enterprise Docker Stack

A production-ready Docker Compose setup for HeavyAI Enterprise with JupyterHub integration. This stack provides a complete environment running HeavyDB, HeavyIQ, Immerse, and JupyterHub with GPU support.

## Features

- 🚀 Service Oriented Architecture (SOA)
- 🔒 SSL/TLS with automatic certificate management via Caddy
- 🎯 Single domain setup with path-based routing
- 🎮 GPU support for HeavyDB (nvidia cuda runtime via docker)
- 📊 JupyterHub integration
- 🔄 All services communicate over internal Docker network
- 💾 Organized data storage with relative paths
- ⚙️ Fully configurable via environment variables

## Prerequisites

- Ubuntu 22.04 or later
- Docker Engine 20.10+
- Docker Compose V2 (not "docker-compose" command)
- NVIDIA GPU with drivers installed (`watch nvidia-smi`)
- NVIDIA Container Toolkit
- Domain name pointed to your server (A Record in DNS)

## Directory Structure

```
.
├── configs/                   # Configuration files
│   ├── Caddyfile            # Caddy reverse proxy config
│   ├── heavydb.conf         # HeavyDB configuration
│   ├── immerse.conf         # Immerse configuration
│   ├── iq.conf             # HeavyIQ configuration
│   ├── jupyterhub/         # JupyterHub configs
│   │   ├── Dockerfile.jupyterhub
│   │   └── jupyterhub_config.py
│   └── servers.json        # Immerse servers configuration
├── data/                    # Data directories (gitignored)
│   ├── caddy/              # Caddy data
│   │   ├── config/        # Caddy config storage
│   │   └── data/         # Caddy data storage
│   ├── heavyai/            # HeavyAI data
│   │   ├── storage/      # HeavyDB storage
│   │   ├── import/       # Import directory
│   │   ├── export/       # Export directory
│   │   ├── iq/          # HeavyIQ data
│   │   └── immerse/     # Immerse data
│   └── jupyterhub/        # JupyterHub data
├── docker-compose.yml      # Main compose file
├── .env.example           # Example environment variables
├── .gitignore            # Git ignore file
├── README.md             # This file
└── setup.sh             # Setup script
```

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/heavyai-enterprise-stack.git
cd heavyai-enterprise-stack
```

2. Run the setup script:
```bash
chmod +x setup.sh
./setup.sh
```

3. Configure your environment:
```bash
cp .env.example .env
# Edit .env with your settings
nano .env
```

4. Start the stack:
```bash
docker compose up -d
```

## Services and Ports

| Service     | Internal Port | Path     |
|------------|--------------|----------|
| HeavyDB    | 6274        | -        |
| Immerse    | 6273        | /        |
| HeavyIQ    | 6275        | -        |
| JupyterHub | 8000        | /jupyter |

## Environment Variables

Key environment variables that need to be configured:

```bash
# Domain name
DOMAIN=example.com

# Heavy.AI image
HEAVYAI_IMAGE=heavyai/heavyai-ee-cuda:latest

# GPU configuration
GPU_COUNT=1
GPU_DEVICE_IDS=0

# JupyterHub configuration
JUPYTERHUB_ADMIN=admin
```

See `.env.example` for all available options.

## URLs

After deployment, services will be available at:

- Immerse UI: `https://your-domain.com/`
- JupyterHub: `https://your-domain.com/jupyter`

## GPU Support

The stack is configured to use NVIDIA GPUs. Make sure you have:

1. NVIDIA drivers installed
2. NVIDIA Container Toolkit installed
3. Docker configured to use NVIDIA runtime

You can adjust GPU allocation in the `.env` file:

```bash
GPU_COUNT=1  # Number of GPUs to allocate
GPU_DEVICE_IDS=0  # Specific GPU device IDs to use
```

## Security

- All services communicate over an internal Docker network
- SSL/TLS certificates are automatically managed by Caddy
- Services are not exposed directly, only through the reverse proxy
- JupyterHub uses authentication (configure in production)

## Data Persistence

All data is stored in the `./data` directory:

- `data/heavyai/`: HeavyDB, Immerse, and HeavyIQ data
- `data/jupyterhub/`: JupyterHub data
- `data/caddy/`: Caddy certificates and config

## Development

To modify configurations:

1. Edit files in the `configs/` directory
2. Restart the affected service:
```bash
docker compose restart <service-name>
```

## Production Deployment

For production deployment:

1. Use strong passwords
2. Configure proper authentication for JupyterHub
3. Set up regular backups of the data directory
4. Configure appropriate resource limits
5. Use a proper SSL provider
6. Set up monitoring and logging

## Troubleshooting

Common issues and solutions:

1. GPU not available:
   - Check NVIDIA drivers
   - Verify NVIDIA Container Toolkit
   - Check docker info for NVIDIA runtime

2. Services not starting:
   - Check logs: `docker compose logs <service>`
   - Verify configurations
   - Check port availability

3. SSL issues:
   - Verify domain DNS settings
   - Check Caddy logs
   - Ensure ports 80/443 are available

## References
- [HEAVY.AI Installation using Docker on Ubuntu](https://docs.heavy.ai/installation-and-configuration/installation/install-docker/docker-enterprise-edition-gpu)
- [Install NVIDIA Drivers and Vulkan on Ubuntu](https://docs.heavy.ai/installation-and-configuration/installation/installing-on-ubuntu/install-nvidia-drivers-and-vulkan-on-ubuntu))
- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)

---

This documentation provides a detailed guide for deploying HeavyAI with GPU support using Docker Compose.

