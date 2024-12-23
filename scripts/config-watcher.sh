#!/bin/bash

echo "Creating required directories..."

# Create HeavyAI directories
mkdir -p "${HEAVY_STORAGE_DIR}"
mkdir -p "${HEAVYDB_IMPORT_PATH}"
mkdir -p "${HEAVYDB_EXPORT_PATH}"
mkdir -p "${HEAVY_IQ_LOCATION}/log"
mkdir -p "${HEAVY_IMMERSE_LOCATION}"

# Create directory for processed configs
mkdir -p "$(dirname ${HEAVYDB_CONFIG_FILE})"
mkdir -p "$(dirname ${HEAVY_IMMERSE_CONFIG_FILE})"
mkdir -p "$(dirname ${HEAVY_IQ_CONFIG_FILE})"
mkdir -p "$(dirname ${IMMERSE_SERVERS_JSON})"

echo "Processing config files..."

# Process heavydb.conf
envsubst < /configs/heavydb.conf > "${HEAVYDB_CONFIG_FILE}"

# Process immerse.conf
envsubst < /configs/immerse.conf > "${HEAVY_IMMERSE_CONFIG_FILE}"

# Process iq.conf
envsubst < /configs/iq.conf > "${HEAVY_IQ_CONFIG_FILE}"

# Process servers.json
envsubst < /configs/servers.json > "${IMMERSE_SERVERS_JSON}"

echo "Config files processed"

# Keep container running
tail -f /dev/null