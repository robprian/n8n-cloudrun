# ROBRION-N8N - Advanced n8n on Google Cloud Run

Advanced n8n workflow automation deployment on Google Cloud Run with enhanced features, monitoring, and persistent storage.

## 🚀 Features

- **Advanced n8n Setup**: Latest n8n with optimized configuration
- **Persistent Storage**: SQLite database with Google Cloud Storage
- **Enhanced Monitoring**: Built-in health checks and logging
- **Auto-scaling**: Cloud Run with intelligent scaling
- **Security**: Service account authentication
- **Easy Deployment**: One-click deployment script

## 📁 Project Structure

```
robrion-n8n/
├── Dockerfile          # Enhanced Docker configuration
├── startup.sh          # Advanced startup script with monitoring
├── healthcheck.sh       # Health monitoring script
├── cloudbuild.yml       # Google Cloud Build configuration
├── service-account-key.json  # Service account credentials
└── README.md           # This file
```

## 🔧 Quick Setup

1. **Deploy**:
   ```bash
   gcloud builds submit --config=cloudbuild.yml .
   ```

## 🏗️ Manual Deployment

```bash
# Authenticate
gcloud auth activate-service-account --key-file=service-account-key.json

# Set project
gcloud config set project stately-lambda-463716-s3

# Deploy
gcloud builds submit --config=cloudbuild.yml .
```

## ⚙️ Configuration

### Environment Variables
- `ROBRION_VERSION`: Application version
- `ROBRION_ENVIRONMENT`: Environment (production/staging)
- `N8N_DB_SQLITE_FILE`: Database file path
- `N8N_LOG_LEVEL`: Logging level

### Resources
- **Memory**: 1GB
- **CPU**: 2 vCPU
- **Scaling**: 0-3 instances
- **Storage**: Google Cloud Storage bucket

## 🔍 Monitoring

Access your deployment:
- **n8n Interface**: `https://YOUR_CLOUDRUN_URL`
- **Health Check**: `https://YOUR_CLOUDRUN_URL/healthz`
- **Logs**: `gcloud logs read --service=robrion-n8n`

## 📊 Advanced Features

- **Persistent Workflows**: Stored in Cloud Storage
- **Binary Data Storage**: Filesystem-based storage
- **Execution History**: Full execution tracking
- **Automated Backups**: Built-in backup system
- **Performance Monitoring**: System metrics logging

## 🛠️ Troubleshooting

Common issues and solutions:

1. **Database Connection**: Check Cloud Storage bucket permissions
2. **Memory Issues**: Increase memory allocation in `cloudbuild.yml`
3. **Cold Starts**: Adjust min instances in deployment config

## � License

MIT License - feel free to use and modify.
robrion-n8n/
├── 🐳 Dockerfile              # Enhanced Docker configuration
├── 🚀 startup.sh              # Advanced startup script with monitoring
├── 🏥 healthcheck.sh          # Comprehensive health check system
├── ☁️ cloudbuild.yml          # Advanced Cloud Build pipeline
├── 📚 README.md               # This documentation
└── 🔧 .env.example            # Environment variables template
```
## 🚀 Quick Start

### Prerequisites
1. **Google Cloud Project** with billing enabled
2. **Enable APIs**:
   ```bash
   gcloud services enable run.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   gcloud services enable storage.googleapis.com
   ```

3. **Create Resources**:
   ```bash
   # Create Cloud Storage bucket
   gsutil mb gs://robrion-n8n-storage
   
   # Set bucket permissions
   gsutil iam ch allUsers:objectViewer gs://robrion-n8n-storage
   ```

### 🎯 Deployment Options

#### Option 1: Automatic Deployment (Recommended)
1. Fork this repository
2. Connect to Google Cloud Build
3. Update `cloudbuild.yml` with your project details
4. Push changes to trigger deployment

#### Option 2: Manual Deployment
```bash
# Clone repository
git clone https://github.com/yourusername/robrion-n8n.git
cd robrion-n8n

# Build and deploy
gcloud builds submit --config cloudbuild.yml
```

#### Option 3: Local Build & Deploy
```bash
# Build Docker image
docker build -t gcr.io/YOUR_PROJECT_ID/robrion-n8n:latest .

# Push to registry
docker push gcr.io/YOUR_PROJECT_ID/robrion-n8n:latest

# Deploy to Cloud Run
gcloud run deploy robrion-n8n \
  --image gcr.io/YOUR_PROJECT_ID/robrion-n8n:latest \
  --region us-central1 \
  --platform managed \
  --memory 1Gi \
  --cpu 2 \
  --min-instances 1 \
  --max-instances 3 \
  --allow-unauthenticated \
  --set-env-vars ROBRION_VERSION=1.0.0,ROBRION_ENVIRONMENT=production \
  --add-volume name=robrion-storage,type=cloud-storage,bucket=robrion-n8n-storage \
  --add-volume-mount volume=robrion-storage,mount-path=/mnt/data
```

## ⚙️ Advanced Configuration

### 🔧 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ROBRION_VERSION` | `1.0.0` | ROBRION-N8N version |
| `ROBRION_ENVIRONMENT` | `production` | Environment type |
| `N8N_LOG_LEVEL` | `info` | Logging level |
| `N8N_EXECUTIONS_DATA_SAVE_ON_ERROR` | `all` | Save execution data on error |
| `N8N_EXECUTIONS_DATA_SAVE_ON_SUCCESS` | `all` | Save execution data on success |
| `N8N_EXECUTIONS_DATA_PRUNE` | `true` | Auto-prune old executions |
| `N8N_EXECUTIONS_DATA_MAX_AGE` | `168` | Max age in hours |
| `N8N_BINARY_DATA_MODE` | `filesystem` | Binary data storage mode |

### 🏥 Health Monitoring

ROBRION-N8N includes comprehensive health monitoring:

- **System Resources**: CPU, Memory, Disk usage
- **Database Health**: Connection and file integrity
- **Service Endpoints**: API and webhook availability
- **Log Monitoring**: Automatic log rotation and analysis

### 📊 Monitoring Dashboard

Access monitoring features:
- **Health Check**: `https://your-service-url/healthz`
- **Metrics**: Available in Google Cloud Monitoring
- **Logs**: `/mnt/data/logs/` directory
- **System Logs**: `/mnt/data/logs/system.log`

## 🔒 Security & Best Practices

### 🛡️ Security Features
- **Container Security**: Non-root user execution
- **Resource Limits**: CPU and memory constraints
- **Health Checks**: Automatic restart on failures
- **Data Encryption**: At rest and in transit

### 🔐 Production Recommendations
```bash
# Enable authentication
gcloud run services add-iam-policy-binding robrion-n8n \
  --member=user:your-email@domain.com \
  --role=roles/run.invoker

# Set up custom domain
gcloud run domain-mappings create \
  --service=robrion-n8n \
  --domain=your-domain.com
```

## 🚀 Performance Optimization

### 📈 Resource Tuning
- **Memory**: 1Gi (recommended for complex workflows)
- **CPU**: 2 vCPU (for parallel processing)
- **Instances**: Min 1, Max 3 (auto-scaling)
- **Concurrency**: 100 requests per instance

### ⚡ Performance Tips
1. **Database Optimization**: Regular SQLite maintenance
2. **Binary Data**: Use filesystem mode for large files
3. **Execution Pruning**: Automatic cleanup of old executions
4. **Caching**: Built-in caching for frequently accessed data

## 🔧 Troubleshooting Guide

### Common Issues & Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Database Lock | Workflow execution fails | Restart service, check concurrent access |
| Memory Issues | Container restarts | Increase memory allocation |
| Storage Full | Write errors | Check disk usage, enable pruning |
| Health Check Fails | Service unavailable | Check logs, verify endpoints |

### 🔍 Debugging Commands
```bash
# View logs
gcloud logs read --service=robrion-n8n --limit=50

# Check service status
gcloud run services describe robrion-n8n --region=us-central1

# Test health check
curl -f https://your-service-url/healthz

# Access container shell (for debugging)
gcloud run services proxy robrion-n8n --port=8080
```

## 📚 Advanced Features

### 🔄 Backup & Recovery
- **Automated Backups**: Daily database snapshots
- **Export Workflows**: JSON export functionality
- **Disaster Recovery**: Multi-region deployment support

### 🔌 Integration Options
- **API Access**: RESTful API for external integrations
- **Webhooks**: Advanced webhook handling
- **Custom Nodes**: Support for custom n8n nodes
- **External Services**: Pre-configured connectors

### 🎯 Workflow Management
- **Version Control**: Git-based workflow versioning
- **Environment Promotion**: Dev → Staging → Production
- **Monitoring**: Workflow execution monitoring
- **Alerting**: Custom alerts for workflow failures

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** your changes
4. **Push** to the branch
5. **Create** a Pull Request

### Development Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/robrion-n8n.git
cd robrion-n8n

# Build locally
docker build -t robrion-n8n:dev .

# Run locally
docker run -p 8080:8080 robrion-n8n:dev
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📧 **Email**: support@robrion.com
- 💬 **Discord**: [Join our community](https://discord.gg/robrion)
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/robrion-n8n/issues)
- 📖 **Documentation**: [Full Documentation](https://docs.robrion.com/n8n)

## 🙏 Acknowledgments

- [n8n Team](https://n8n.io/) for the amazing workflow automation tool
- [Google Cloud](https://cloud.google.com/) for the robust cloud platform
- Community contributors and testers

---

<div align="center">
<p><strong>ROBRION-N8N</strong> - Advanced n8n Cloud Deployment</p>
<p>Made with ❤️ by <a href="https://github.com/yourusername">Robrion</a></p>
</div>
                                               2. Create a feature branch
                                               3. Make your changes
                                               4. Test the deployment
                                               5. Submit a pull request

                                               ## 📄 License

                                               This project is open source and available under the [MIT License](LICENSE).