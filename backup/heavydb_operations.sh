#!/bin/bash
#set -e  # Uncomment to exit on error
#set -o pipefail  # Uncomment to exit if any command in a pipeline fails
#set -x  # Uncomment for debug mode: prints each command before execution

###############################
# HeavyDB & Docker Credentials
###############################
HEAVYDB_USER="admin"
HEAVYDB_PASS="HyperInteractive"
HEAVYDB_DB="heavyai"
CONTAINER_NAME="heavydb"    # Your HeavyAI Docker container name

###############################
# AWS S3 (Hetzner Object Storage) Credentials
###############################
S3_BUCKET="heavydb"         # Your S3 bucket name (without the s3:// prefix)
S3_REGION=""                # Your S3 region (e.g., us-east-1)
S3_BACKUP_DIR="backup_heavyai"  # Directory inside S3 bucket

# Hetzner Object Storage specific settings:
HETZNER_ENDPOINT_URL="nbg1.your-objectstorage.com"
HETZNER_ACCESS_KEY=""
HETZNER_SECRET_KEY=""

# Export the Hetzner credentials so that AWS CLI can use them
export AWS_ACCESS_KEY_ID="$HETZNER_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$HETZNER_SECRET_KEY"

###############################
# Local Storage Directories (inside container)
###############################
LOCAL_DUMP_DIR="/var/lib/heavyai/storage/export"
LOCAL_IMPORT_DIR="/var/lib/heavyai/storage/import"

###########################################
# Include the table list associative array
###########################################
if [ ! -f table_list.sh ]; then
  echo "ERROR: table_list.sh not found. Please generate it first using generate_table_list.sh."
  exit 1
fi
source table_list.sh

###########################################
# Ensure required directories exist in container
###########################################
docker exec -i "$CONTAINER_NAME" mkdir -p "$LOCAL_DUMP_DIR" "$LOCAL_IMPORT_DIR"

###########################################
# Status Tracking Files
###########################################
SUCCESS_LOG="backup_success.log"
FAILURE_LOG="backup_failure.log"
> "$SUCCESS_LOG"   # Clear old logs
> "$FAILURE_LOG"   # Clear old logs

###########################################
# Function to dump a table locally
###########################################
dump_table() {
  local table_name="$1"
  local file_name="${TABLES[$table_name]}"
  local local_file_path="$LOCAL_DUMP_DIR/$file_name"

  # Build the DUMP query
  local QUERY="DUMP TABLE $table_name TO '$local_file_path' WITH (compression='gzip');"

  echo "---------------------------------------------------"
  echo "Dumping table: $table_name"
  echo "Exporting to: $local_file_path"
  echo "Executing DUMP command inside HeavyDB Docker..."
  echo "---------------------------------------------------"

  docker exec -i "$CONTAINER_NAME" \
    /opt/heavyai/bin/heavysql -u "$HEAVYDB_USER" -p "$HEAVYDB_PASS" -db "$HEAVYDB_DB" <<< "$QUERY"

  if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: $table_name dumped locally."
    echo "$table_name" >> "$SUCCESS_LOG"
  else
    echo "❌ ERROR: Failed to dump $table_name."
    echo "$table_name" >> "$FAILURE_LOG"
  fi
}

###########################################
# Function to upload a dumped file to S3
###########################################
upload_to_s3() {
  local file_name="$1"
  local local_file_path="$LOCAL_DUMP_DIR/$file_name"

  echo "---------------------------------------------------"
  echo "Uploading to S3: s3://$S3_BUCKET/$S3_BACKUP_DIR/$file_name"
  echo "---------------------------------------------------"

  aws s3 cp "$local_file_path" "s3://$S3_BUCKET/$S3_BACKUP_DIR/$file_name" \
    --region "$S3_REGION" \
    --endpoint-url "https://$HETZNER_ENDPOINT_URL"

  if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: $file_name uploaded to S3."
    echo "$file_name" >> "$SUCCESS_LOG"
  else
    echo "❌ ERROR: Failed to upload $file_name to S3."
    echo "$file_name" >> "$FAILURE_LOG"
  fi
}

###########################################
# Function to restore a table from S3
###########################################
restore_table() {
  local table_name="$1"
  local file_name="${TABLES[$table_name]}"
  local local_file_path="$LOCAL_IMPORT_DIR/$file_name"

  echo "---------------------------------------------------"
  echo "Downloading from S3: s3://$S3_BUCKET/$S3_BACKUP_DIR/$file_name"
  echo "Saving to: $LOCAL_IMPORT_DIR"
  echo "---------------------------------------------------"

  aws s3 cp "s3://$S3_BUCKET/$S3_BACKUP_DIR/$file_name" "$LOCAL_IMPORT_DIR/" \
    --region "$S3_REGION" \
    --endpoint-url "https://$HETZNER_ENDPOINT_URL"

  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Failed to download $file_name from S3."
    echo "$table_name" >> "$FAILURE_LOG"
    return
  fi
  echo "✅ SUCCESS: $file_name downloaded from S3."

  # Build the RESTORE query
  local QUERY="RESTORE TABLE $table_name FROM '$local_file_path' WITH (compression='gzip');"

  echo "Executing RESTORE command inside HeavyDB Docker..."
  docker exec -i "$CONTAINER_NAME" \
    /opt/heavyai/bin/heavysql -u "$HEAVYDB_USER" -p "$HEAVYDB_PASS" -db "$HEAVYDB_DB" <<< "$QUERY"

  if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: $table_name restored."
    echo "$table_name" >> "$SUCCESS_LOG"
  else
    echo "❌ ERROR: Failed to restore $table_name."
    echo "$table_name" >> "$FAILURE_LOG"
  fi
}

###########################################
# Upload `table_list.sh` to S3 if found
###########################################
upload_table_list() {
  if [ -f table_list.sh ]; then
    aws s3 cp "table_list.sh" "s3://$S3_BUCKET/$S3_BACKUP_DIR/table_list.sh" \
      --region "$S3_REGION" \
      --endpoint-url "https://$HETZNER_ENDPOINT_URL"
    echo "✅ SUCCESS: table_list.sh uploaded to S3."
  fi
}

###########################################
# Check if HeavyDB Docker container is running
###########################################
if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "❌ ERROR: HeavyDB container ($CONTAINER_NAME) is not running!"
  exit 1
fi

###########################################
# User Operation Choice
###########################################
echo "Choose an operation:"
echo "1) Dump tables locally"
echo "2) Upload dumped tables to S3"
echo "3) Restore tables from S3"
read -p "Enter choice (1, 2, or 3): " choice

case $choice in
  1)
    echo "🚀 Starting local table dump..."
    for table in "${!TABLES[@]}"; do
      dump_table "$table"
    done
    echo "✅ ALL TABLES DUMPED LOCALLY TO $LOCAL_DUMP_DIR!"
    ;;
  2)
    echo "🚀 Starting upload of dumped tables to S3..."
    upload_table_list  # Upload table_list.sh first
    for table in "${!TABLES[@]}"; do
      upload_to_s3 "${TABLES[$table]}"
    done
    echo "✅ ALL TABLES UPLOADED TO S3!"
    ;;
  3)
    echo "🚀 Starting table restore from S3..."
    for table in "${!TABLES[@]}"; do
      restore_table "$table"
    done
    echo "✅ ALL TABLES RESTORED SUCCESSFULLY!"
    ;;
  *)
    echo "❌ Invalid choice! Please enter 1, 2, or 3."
    exit 1
    ;;
esac
