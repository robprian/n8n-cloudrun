# ========================================
# ROBRION-N8N ADVANCED CLOUD RUN DOCKERFILE
# Enhanced n8n deployment with monitoring
# ========================================

FROM docker.n8n.io/n8nio/n8n:latest

# Metadata
LABEL maintainer="Robrion"
LABEL description="Advanced n8n deployment for Cloud Run with enhanced features"
LABEL version="1.0.0"
LABEL robrion.n8n.variant="cloud-run"

# Switch to root for setup operations
USER root

# Install additional tools for monitoring and debugging
RUN apk update && apk add --no-cache \
    curl \
    sqlite \
    htop \
    nano \
    procps

# Create advanced directory structure
RUN mkdir -p /mnt/data/logs && \
    mkdir -p /mnt/data/backups && \
    mkdir -p /mnt/data/exports && \
    mkdir -p /mnt/data/workflows && \
    mkdir -p /mnt/data/binary-data && \
    mkdir -p /mnt/data/credentials && \
    chown -R node:node /mnt/data

# Copy enhanced scripts
COPY startup.sh /home/node/startup.sh
COPY healthcheck.sh /home/node/healthcheck.sh

# Create monitoring script
RUN echo '#!/bin/bash\n\
# ROBRION-N8N Monitoring Script\n\
while true; do\n\
    echo "$(date): CPU: $(top -bn1 | grep "Cpu(s)" | awk '\''{print $2}'\'' | cut -d'\''%'\'' -f1)%" >> /mnt/data/logs/monitor.log\n\
    echo "$(date): Memory: $(free -h | grep Mem | awk '\''{print $3 "/" $2}'\'')" >> /mnt/data/logs/monitor.log\n\
    sleep 60\n\
done' > /home/node/monitor.sh

# Set proper permissions for all scripts
RUN chmod +x /home/node/startup.sh /home/node/healthcheck.sh /home/node/monitor.sh && \
    chown -R node:node /home/node

# Switch back to node user for security
USER node

# Expose the port that n8n will run on
EXPOSE 8080

# Set ROBRION-N8N environment variables for Cloud Run
ENV PORT=8080
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=8080
ENV N8N_PROTOCOL=http
ENV N8N_LOG_LEVEL=info
ENV N8N_METRICS=true
ENV N8N_DISABLE_UI=false
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV ROBRION_VERSION=1.0.0
ENV ROBRION_ENVIRONMENT=production

# Advanced n8n configuration
ENV N8N_EXECUTIONS_DATA_SAVE_ON_ERROR=all
ENV N8N_EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
ENV N8N_EXECUTIONS_DATA_SAVE_ON_PROGRESS=true
ENV N8N_EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
ENV N8N_EXECUTIONS_DATA_PRUNE=true
ENV N8N_EXECUTIONS_DATA_MAX_AGE=168
ENV N8N_BINARY_DATA_MODE=filesystem

# Add enhanced health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD /home/node/healthcheck.sh

# Use ROBRION-N8N startup script as entrypoint
ENTRYPOINT ["/home/node/startup.sh"]