#!/bin/bash
# generate_table_list.sh
# This script queries HeavyDB for the list of tables and outputs an associative array
# that can be sourced by another script.

# HeavyDB credentials (inside the container)
HEAVYDB_USER="admin"
HEAVYDB_PASS="HyperInteractive"
HEAVYDB_DB="heavyai"

# HeavyAI Docker container name
CONTAINER_NAME="heavydb"

# Define an array of ignored tables
IGNORED_TABLES=("from" "database" "disconnected" "admin" "User" "table_name" "heavyai")

# Query HeavyDB for the list of tables
TABLE_LIST=$(docker exec -i "$CONTAINER_NAME" \
  /opt/heavyai/bin/heavysql -u "$HEAVYDB_USER" -p "$HEAVYDB_PASS" -db "$HEAVYDB_DB" <<< "SHOW TABLES;" | tail -n +2)

# Function to check if a table is in the ignored list
is_ignored() {
  local table=$1
  for ignored in "${IGNORED_TABLES[@]}"; do
    if [[ "$table" == "$ignored" ]]; then
      return 0  # Found in ignored list
    fi
  done
  return 1  # Not in ignored list
}

# Output the associative array definition
echo "# Define the list of tables and corresponding filenames"
echo "declare -A TABLES"
echo "TABLES=("
for table in $TABLE_LIST; do
  # Remove any leading/trailing whitespace
  table=$(echo "$table" | xargs)
  
  if [ -n "$table" ] && ! is_ignored "$table"; then
    echo "  [\"$table\"]=\"$table.gz\""
  fi
done
echo ")"