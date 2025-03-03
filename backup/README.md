# HeavyDB Backup and Restore System

This directory contains scripts for backing up and restoring HeavyDB tables. The backup system supports local dumps and remote storage via S3-compatible object storage (such as Hetzner).

## Overview

The backup system consists of two main scripts:

1. `generate_table_list.sh` - Automatically discovers and lists all tables in your HeavyDB instance
2. `heavydb_operations.sh` - Performs backup and restore operations for all discovered tables

## Features

- Automated table discovery
- Compression with gzip
- Local backup storage
- Remote backup via S3-compatible storage
- Selective table backup and restore
- Success and failure logging

## Prerequisites

Before using these scripts, ensure you have:

1. A running HeavyDB Docker container
2. AWS CLI installed for S3 operations
3. Proper permissions to execute the scripts

```bash
# Install AWS CLI if not already installed
apt-get update
apt-get install -y awscli
```

## Configuration

1. Update credentials in `heavydb_operations.sh` and `generate_table_list.sh`:
   - HeavyDB credentials
   - S3 bucket and region
   - Hetzner Object Storage credentials (if using Hetzner)

## Usage

### Step 1: Generate the Table List

First, generate a list of tables from your HeavyDB instance:

```bash
cd backup
chmod +x generate_table_list.sh
./generate_table_list.sh > table_list.sh
```

This creates a `table_list.sh` file containing an associative array of all tables in your HeavyDB instance.

### Step 2: Run Backup or Restore Operations

Execute the operations script to perform backups or restores:

```bash
chmod +x heavydb_operations.sh
./heavydb_operations.sh
```

The script will provide an interactive menu with the following options:

1. **Dump tables locally** - Exports tables from HeavyDB to local compressed files
2. **Upload dumped tables to S3** - Uploads previously dumped tables to S3-compatible storage
3. **Restore tables from S3** - Downloads and imports tables from S3-compatible storage

## Logs

The system maintains two log files:
- `backup_success.log` - Lists successful operations
- `backup_failure.log` - Lists failed operations

## Customization

By default, the following tables are excluded from backup/restore operations:
- `from`
- `database`
- `disconnected`
- `admin`
- `User`
- `table_name`
- `heavyai`

To modify this list, edit the `IGNORED_TABLES` array in `generate_table_list.sh`.

## Troubleshooting

- Ensure Docker container is running before executing scripts
- Verify AWS CLI is correctly installed and configured
- Check storage permissions for export/import directories