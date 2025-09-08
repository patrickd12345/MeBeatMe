# MeBeatMe Subdomain Integration Guide

This guide explains how to integrate MeBeatMe as a subdomain under your existing ready2race.me domain.

## 🌐 Domain Structure

- **Main Domain**: `ready2race.me`
- **MeBeatMe Subdomain**: `mebeatme.ready2race.me`
- **API Endpoints**: `https://mebeatme.ready2race.me/api/v1/`

## 🚀 Quick Deployment

### Option 1: Docker Deployment (Recommended)

```bash
# Build and deploy with Docker Compose
cd deployment
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f mebeatme-server
```

### Option 2: Manual Deployment

```bash
# Run the deployment script
sudo ./deployment/deploy-subdomain.sh
```

## 📋 Prerequisites

### DNS Configuration
Add the following DNS records to your ready2race.me domain:

```
Type: A
Name: mebeatme
Value: [YOUR_SERVER_IP]
TTL: 300
```

### SSL Certificate
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d mebeatme.ready2race.me
```

### Server Requirements
- Ubuntu 20.04+ or similar Linux distribution
- Java 17+
- Nginx
- Docker (optional)

## 🔧 Configuration Files

### Environment Configuration
Copy `config.env.example` to `.env` and update with your values:

```bash
cp config.env.example .env
# Edit .env with your actual configuration
```

### Nginx Configuration
The nginx configuration is automatically installed by the deployment script:
- **File**: `/etc/nginx/sites-available/mebeatme.ready2race.me`
- **Enabled**: `/etc/nginx/sites-enabled/mebeatme.ready2race.me`

### Systemd Service
The MeBeatMe server runs as a systemd service:
- **Service**: `mebeatme-server`
- **Status**: `systemctl status mebeatme-server`
- **Logs**: `journalctl -u mebeatme-server -f`

## 🌍 API Endpoints

### Production URLs
- **Health Check**: `https://mebeatme.ready2race.me/health`
- **API Bests**: `https://mebeatme.ready2race.me/api/v1/sync/bests`
- **API Sessions**: `https://mebeatme.ready2race.me/api/v1/sync/sessions`
- **Upload Session**: `POST https://mebeatme.ready2race.me/api/v1/sync/upload`

### Development URLs
- **Health Check**: `http://localhost:8080/health`
- **API Bests**: `http://localhost:8080/api/v1/sync/bests`

## 📱 Client Configuration

### watchOS App
The watchOS app automatically detects the environment:
- **Debug**: Uses `http://localhost:8080`
- **Release**: Uses `https://mebeatme.ready2race.me`

### Web Dashboard
The web dashboard automatically detects the domain:
- **Production**: Uses `https://mebeatme.ready2race.me`
- **Development**: Uses `http://localhost:8080`

## 🔒 Security Features

### CORS Configuration
- **Allowed Origins**: `https://mebeatme.ready2race.me`, `https://ready2race.me`
- **Allowed Methods**: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`
- **Allowed Headers**: `Content-Type`, `Authorization`, `X-Requested-With`

### SSL/TLS
- **Protocols**: TLSv1.2, TLSv1.3
- **Ciphers**: Modern, secure cipher suites
- **HSTS**: Enabled with subdomain inclusion

### Security Headers
- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`

## 📊 Monitoring

### Health Checks
```bash
# Check server health
curl https://mebeatme.ready2race.me/health

# Check API endpoints
curl https://mebeatme.ready2race.me/api/v1/sync/bests
```

### Logs
```bash
# Server logs
journalctl -u mebeatme-server -f

# Nginx logs
tail -f /var/log/nginx/mebeatme.ready2race.me.access.log
tail -f /var/log/nginx/mebeatme.ready2race.me.error.log
```

### Metrics
- **Health Check**: Every 30 seconds
- **Service Status**: `systemctl status mebeatme-server`
- **Resource Usage**: `htop` or `docker stats`

## 🔄 Updates and Maintenance

### Updating the Application
```bash
# Pull latest changes
git pull origin main

# Rebuild and redeploy
./gradlew :server:build :web:build
sudo systemctl restart mebeatme-server
```

### Database Migrations
```bash
# Run migrations (when database is added)
./gradlew :server:migrate
```

### Backup
```bash
# Backup application data
tar -czf mebeatme-backup-$(date +%Y%m%d).tar.gz \
    /var/www/mebeatme \
    /var/uploads/mebeatme \
    /var/log/mebeatme
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Service Won't Start
```bash
# Check service status
systemctl status mebeatme-server

# Check logs
journalctl -u mebeatme-server -f

# Check Java version
java -version
```

#### 2. Nginx Configuration Issues
```bash
# Test nginx configuration
nginx -t

# Reload nginx
systemctl reload nginx
```

#### 3. SSL Certificate Issues
```bash
# Check certificate
openssl x509 -in /etc/ssl/certs/mebeatme.ready2race.me.crt -text -noout

# Renew certificate
certbot renew
```

#### 4. CORS Issues
Check that the CORS_ORIGINS environment variable includes your domain:
```bash
echo $CORS_ORIGINS
```

### Debug Mode
```bash
# Enable debug logging
export LOG_LEVEL=DEBUG
systemctl restart mebeatme-server
```

## 📈 Performance Optimization

### Nginx Caching
Static assets are cached for 1 year:
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Compression
Gzip compression is enabled for all text-based content.

### Rate Limiting
API endpoints have rate limiting configured:
- **Requests**: 100 per hour
- **Window**: 3600 seconds

## 🔗 Integration with ready2race.me

### Cross-Domain Communication
The MeBeatMe subdomain can communicate with the main ready2race.me domain through:
- **CORS**: Configured for both domains
- **API**: Shared authentication tokens
- **Cookies**: Shared domain cookies

### Shared Resources
- **SSL Certificates**: Can be shared or separate
- **Authentication**: Can integrate with main domain auth
- **Analytics**: Can share analytics data

## 📞 Support

For issues with the subdomain integration:
1. Check the troubleshooting section above
2. Review logs for error messages
3. Test endpoints individually
4. Verify DNS and SSL configuration

## 🎯 Next Steps

After successful deployment:
1. **Test all endpoints** to ensure functionality
2. **Configure monitoring** for production use
3. **Set up backups** for data persistence
4. **Integrate with main domain** authentication if needed
5. **Deploy watchOS app** with production configuration
