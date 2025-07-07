#!/bin/sh
set -e

# ========================================
# ROBRION-N8N CLOUD RUN STARTUP SCRIPT
# Advanced n8n deployment with enhanced features
# ========================================

# Set default values
PORT=${PORT:-8080}
N8N_DB_SQLITE_FILE=${N8N_DB_SQLITE_FILE:-/mnt/data/database.sqlite}
ROBRION_VERSION=${ROBRION_VERSION:-"1.0.0"}
ROBRION_ENVIRONMENT=${ROBRION_ENVIRONMENT:-"production"}

echo "=== ROBRION-N8N Cloud Run Startup Script v${ROBRION_VERSION} ==="
echo "Environment: ${ROBRION_ENVIRONMENT}"
echo "Timestamp: $(date)"
echo "Port: ${PORT}"
echo "Database file: ${N8N_DB_SQLITE_FILE}"
echo "Host: ${N8N_HOST:-0.0.0.0}"
echo "Memory info: $(cat /proc/meminfo | grep MemTotal)"
echo "Disk space: $(df -h /mnt/data 2>/dev/null || echo 'Volume not yet mounted')"

# Wait for volume mount to be available with exponential backoff
echo "Checking volume mount availability..."
i=1
while [ $i -le 15 ]; do
    if [ -d "/mnt/data" ] && [ -w "/mnt/data" ]; then
        echo "Volume mount is ready at attempt $i"
        break
    fi
    echo "Waiting for volume mount... (attempt $i/15)"
    if [ $i -eq 15 ]; then
        echo "ERROR: Volume mount failed after 15 attempts (30 seconds)"
        echo "Directory listing of /mnt:"
        ls -la /mnt/ || echo "Cannot list /mnt directory"
        echo "Checking if /mnt/data exists but is not writable:"
        ls -la /mnt/data || echo "/mnt/data does not exist"
        exit 1
    fi
    sleep 2
    i=$((i + 1))
done

# Verify we can write to the data directory
if [ ! -w "/mnt/data" ]; then
    echo "ERROR: Cannot write to /mnt/data directory"
    echo "Directory permissions:"
    ls -la /mnt/data
    exit 1
fi

# Create database directory if it doesn't exist
echo "Creating database directory..."
mkdir -p "$(dirname "$N8N_DB_SQLITE_FILE")"
echo "Database directory created: $(dirname "$N8N_DB_SQLITE_FILE")"

# Test database file creation
echo "Testing database file access..."
touch "$N8N_DB_SQLITE_FILE" || {
    echo "ERROR: Cannot create database file at $N8N_DB_SQLITE_FILE"
    exit 1
}
echo "Database file access confirmed"

# Advanced health monitoring and logging setup
echo "=== ROBRION-N8N Health Monitoring Setup ==="
echo "Setting up advanced monitoring and logging..."

# Create logs directory
mkdir -p /mnt/data/logs
mkdir -p /mnt/data/backups
mkdir -p /mnt/data/exports

# Advanced logging configuration
export N8N_LOG_FILE=/mnt/data/logs/n8n.log
export N8N_LOG_LEVEL=${N8N_LOG_LEVEL:-info}

# Performance monitoring
echo "=== System Performance Monitoring ==="
echo "CPU cores: $(nproc)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk space: $(df -h /mnt/data 2>/dev/null || echo 'Volume not yet mounted')"

# Advanced n8n environment variables for Cloud Run
export N8N_HOST=0.0.0.0
export N8N_PORT=$PORT
export N8N_PROTOCOL=http
export N8N_LOG_LEVEL=info
export N8N_METRICS=true
export N8N_DISABLE_UI=false
export N8N_BASIC_AUTH_ACTIVE=false
export N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true

# ROBRION-N8N Advanced Features
export N8N_WORKFLOWS_FOLDER=/mnt/data/workflows
export N8N_EXECUTIONS_DATA_SAVE_ON_ERROR=all
export N8N_EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
export N8N_EXECUTIONS_DATA_SAVE_ON_PROGRESS=true
export N8N_EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
export N8N_EXECUTIONS_DATA_PRUNE=true
export N8N_EXECUTIONS_DATA_MAX_AGE=168
export N8N_BINARY_DATA_MODE=filesystem
export N8N_BINARY_DATA_STORAGE_PATH=/mnt/data/binary-data

# Create necessary directories
mkdir -p /mnt/data/workflows
mkdir -p /mnt/data/binary-data
mkdir -p /mnt/data/credentials

# Set proper permissions
chmod 755 /mnt/data/workflows
chmod 755 /mnt/data/binary-data
chmod 700 /mnt/data/credentials

# Set additional n8n environment variables for Cloud Run

echo "=== ROBRION-N8N Final Configuration ==="
echo "N8N_HOST: ${N8N_HOST}"
echo "N8N_PORT: ${N8N_PORT}"
echo "N8N_PROTOCOL: ${N8N_PROTOCOL}"
echo "N8N_DB_SQLITE_FILE: ${N8N_DB_SQLITE_FILE}"
echo "N8N_LOG_LEVEL: ${N8N_LOG_LEVEL}"
echo "N8N_LOG_FILE: ${N8N_LOG_FILE}"
echo "Binary Data Path: ${N8N_BINARY_DATA_STORAGE_PATH}"
echo "Workflows Folder: ${N8N_WORKFLOWS_FOLDER}"

# Start background monitoring process
echo "=== Starting ROBRION-N8N Background Monitoring ==="
(
    while true; do
        echo "$(date): Memory usage: $(free -h | grep Mem | awk '{print $3}')" >> /mnt/data/logs/system.log
        echo "$(date): Disk usage: $(df -h /mnt/data | tail -1 | awk '{print $3}')" >> /mnt/data/logs/system.log
        sleep 300 # Log every 5 minutes
    done
) &

echo "=== Starting ROBRION-N8N ==="
echo "Command: n8n start"
echo "Timestamp: $(date)"

# Verify port configuration before starting
echo "=== Port Configuration Verification ==="
echo "PORT environment variable: ${PORT}"
echo "N8N_PORT environment variable: ${N8N_PORT}"
echo "N8N_HOST environment variable: ${N8N_HOST}"

# Start n8n with enhanced configuration
echo "=== Starting ROBRION-N8N in foreground ==="
echo "Command: n8n start with advanced configuration"
echo "Timestamp: $(date)"

# Create a healthcheck endpoint
echo "=== Creating ROBRION-N8N Health Check ==="
echo "Health check will be available at http://localhost:${PORT}/healthz"

exec n8n start