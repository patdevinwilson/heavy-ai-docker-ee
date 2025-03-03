#!/bin/bash

# Check if the container is running
if ! docker ps | grep -q "heavyiq"; then
    echo "Error: Container 'heavyiq' is not running."
    exit 1
fi

# Run commands inside the container
docker exec -it heavyiq bash -c "\
    source /opt/heavyai/heavyiq/.venv/bin/activate && \
    pip install llama-index==0.10.68"

# Restart the container
docker restart heavyiq

echo "Hotfix applied successfully."
