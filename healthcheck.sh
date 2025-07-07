#!/bin/bash

# ========================================
# ROBRION-N8N ADVANCED HEALTH CHECK SCRIPT
# Enhanced monitoring and diagnostic tools
# ========================================

PORT=${PORT:-8080}
HOST=${N8N_HOST:-0.0.0.0}
ROBRION_VERSION=${ROBRION_VERSION:-"1.0.0"}

echo "=== ROBRION-N8N Health Check v${ROBRION_VERSION} ==="
echo "Checking ROBRION-N8N health at http://${HOST}:${PORT}"
echo "Timestamp: $(date)"

# Function to check system resources
check_system_resources() {
    echo "=== System Resources Check ==="
    echo "Memory usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "Disk usage: $(df -h /mnt/data 2>/dev/null | tail -1 | awk '{print $3 "/" $2}' || echo 'N/A')"
    echo "CPU load: $(uptime | awk -F'load average:' '{print $2}')"
}

# Function to check database
check_database() {
    echo "=== Database Check ==="
    if [ -f "/mnt/data/database.sqlite" ]; then
        echo "Database file exists: $(ls -lh /mnt/data/database.sqlite | awk '{print $5}')"
        echo "Database last modified: $(stat -c %y /mnt/data/database.sqlite)"
    else
        echo "WARNING: Database file not found"
    fi
}

# Function to check logs
check_logs() {
    echo "=== Logs Check ==="
    if [ -f "/mnt/data/logs/n8n.log" ]; then
        echo "Log file size: $(ls -lh /mnt/data/logs/n8n.log | awk '{print $5}')"
        echo "Recent log entries:"
        tail -n 5 /mnt/data/logs/n8n.log 2>/dev/null || echo "No recent logs"
    else
        echo "Log file not found"
    fi
}

# Perform system checks
check_system_resources
check_database
check_logs

echo "=== ROBRION-N8N Service Health Check ==="

# Enhanced health check with multiple endpoints
for i in {1..30}; do
    # Check main health endpoint
    if curl -f -s "http://${HOST}:${PORT}/healthz" > /dev/null 2>&1; then
        echo "✓ ROBRION-N8N healthz endpoint is responding!"
        
        # Additional checks
        if curl -f -s "http://${HOST}:${PORT}/rest/settings" > /dev/null 2>&1; then
            echo "✓ ROBRION-N8N API is responding!"
        fi
        
        if curl -f -s "http://${HOST}:${PORT}/webhook-test" > /dev/null 2>&1; then
            echo "✓ ROBRION-N8N webhook endpoint is responding!"
        fi
        
        echo "=== ROBRION-N8N Status: HEALTHY ==="
        exit 0
    elif curl -f -s "http://${HOST}:${PORT}" > /dev/null 2>&1; then
        echo "✓ ROBRION-N8N main endpoint is responding!"
        echo "=== ROBRION-N8N Status: HEALTHY ==="
        exit 0
    fi
    echo "Waiting for ROBRION-N8N to be ready... (attempt $i/30)"
    sleep 2
done

echo "❌ ROBRION-N8N health check failed"
echo "=== ROBRION-N8N Status: UNHEALTHY ==="
exit 1