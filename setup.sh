#!/bin/bash

# Create necessary directories
mkdir -p data/heavyai/{storage,import,export,iq,immerse}
mkdir -p data/jupyterhub
mkdir -p data/caddy/{data,config}
mkdir -p configs

# Copy example env file if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
fi

echo "Configuring servers.json..."
if [ ! -f configs/servers.json ]; then
    # Replace environment variables in servers.json
    envsubst < configs/servers.json.template > configs/servers.json
fi

# Copy config files
cp configs/*.conf data/heavyai/
cp configs/servers.json data/heavyai/immerse/

# Set proper permissions
chmod -R 755 data
chmod 600 configs/servers.json
