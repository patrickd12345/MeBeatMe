# 🚀 MeBeatMe Deployment to ready2race.run

## Quick Deployment Guide

Deploy MeBeatMe to `mebeatme.ready2race.run` in just a few steps!

## 📋 Prerequisites

- **Server**: Ubuntu 20.04+ with root access
- **Domain**: ready2race.run DNS control
- **Software**: Java 17+, Nginx, Certbot

## 🚀 One-Command Deployment

```bash
# Upload files to your server, then run:
sudo chmod +x deploy-ready2race.sh
sudo ./deploy-ready2race.sh
```

## 📝 Manual Steps

### 1. **DNS Configuration**
Add this A record to your ready2race.run DNS:
```
Type: A
Name: mebeatme
Value: [YOUR_SERVER_IP]
TTL: 300
```

### 2. **SSL Certificate**
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d mebeatme.ready2race.run
```

### 3. **Strava OAuth Setup**
Update your Strava app settings:
- **Callback URL**: `https://mebeatme.ready2race.run/dashboard.html`
- **Website**: `https://mebeatme.ready2race.run`

## 🌐 Production URLs

- **Dashboard**: https://mebeatme.ready2race.run/
- **Health Check**: https://mebeatme.ready2race.run/health
- **API Endpoints**: https://mebeatme.ready2race.run/api/
- **Strava Integration**: https://mebeatme.ready2race.run/strava/

## 🔧 Management Commands

```bash
# Check service status
sudo systemctl status mebeatme-server

# View logs
sudo journalctl -u mebeatme-server -f

# Restart service
sudo systemctl restart mebeatme-server

# Check nginx status
sudo systemctl status nginx

# Test nginx config
sudo nginx -t
```

## 📊 Features Deployed

✅ **Complete Dashboard**: Manual workout entry, PPI calculation
✅ **Strava Integration**: OAuth authentication, activity import
✅ **API Server**: RESTful endpoints with CORS support
✅ **SSL Security**: HTTPS with proper security headers
✅ **Production Logging**: Comprehensive error tracking
✅ **Health Monitoring**: Service status and metrics

## 🔒 Security Features

- **HTTPS Only**: Automatic HTTP to HTTPS redirect
- **CORS Protection**: Proper cross-origin request handling
- **Security Headers**: XSS, CSRF, and content type protection
- **File Upload Security**: Restricted upload directory
- **Service Isolation**: Runs as www-data user

## 🧪 Testing Deployment

```bash
# Test health endpoint
curl https://mebeatme.ready2race.run/health

# Test API endpoints
curl https://mebeatme.ready2race.run/api/sync/bests

# Test Strava integration
curl https://mebeatme.ready2race.run/strava/test
```

## 📈 Monitoring

- **Service Logs**: `/var/log/mebeatme/`
- **Nginx Logs**: `/var/log/nginx/mebeatme.ready2race.run.*`
- **System Status**: `systemctl status mebeatme-server`

## 🔄 Updates

To update the deployment:
```bash
# Stop service
sudo systemctl stop mebeatme-server

# Update files
sudo cp dashboard.html /var/www/mebeatme/
sudo cp ProductionHttpServer.java /opt/mebeatme/
cd /opt/mebeatme
sudo javac ProductionHttpServer.java

# Restart service
sudo systemctl start mebeatme-server
```

## 🎯 Production Configuration

The deployment includes:
- **Environment Variables**: Domain, CORS, logging configuration
- **Nginx Proxy**: Reverse proxy with SSL termination
- **Systemd Service**: Automatic startup and restart
- **File Permissions**: Secure file access controls
- **Log Rotation**: Automatic log management

## 🚨 Troubleshooting

### Service Won't Start
```bash
# Check logs
sudo journalctl -u mebeatme-server -f

# Check Java installation
java -version

# Check port availability
sudo netstat -tlnp | grep 8080
```

### SSL Issues
```bash
# Renew certificate
sudo certbot renew

# Check certificate
sudo certbot certificates
```

### DNS Issues
```bash
# Test DNS resolution
nslookup mebeatme.ready2race.run

# Check from server
curl -I https://mebeatme.ready2race.run/health
```

---

**🎉 Your MeBeatMe dashboard is now live at https://mebeatme.ready2race.run!**

The deployment includes everything you need:
- Complete workout management
- Strava integration
- PPI calculation
- Production security
- SSL encryption
- Health monitoring
