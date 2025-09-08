#!/bin/bash
# MeBeatMe Deployment Script for ready2race.me subdomain
# This script deploys MeBeatMe as a subdomain under ready2race.me

set -e

# Configuration
DOMAIN="ready2race.me"
SUBDOMAIN="mebeatme"
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
APP_DIR="/var/www/mebeatme"
SERVER_DIR="/opt/mebeatme"
NGINX_CONFIG="/etc/nginx/sites-available/mebeatme.ready2race.me"
NGINX_ENABLED="/etc/nginx/sites-enabled/mebeatme.ready2race.me"
SERVICE_NAME="mebeatme-server"

echo "🚀 Deploying MeBeatMe to ${FULL_DOMAIN}..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# Create directories
echo "📁 Creating directories..."
mkdir -p $APP_DIR
mkdir -p $SERVER_DIR
mkdir -p /var/uploads/mebeatme
mkdir -p /var/log/mebeatme

# Set permissions
chown -R www-data:www-data $APP_DIR
chown -R www-data:www-data /var/uploads/mebeatme
chmod 755 $APP_DIR
chmod 755 /var/uploads/mebeatme

# Build the application
echo "🔨 Building MeBeatMe application..."
cd /path/to/MeBeatMe  # Update this path

# Build KMP shared module
./gradlew :shared:build

# Build server
./gradlew :server:build

# Build web dashboard
./gradlew :web:build

# Copy built files
echo "📦 Copying built files..."
cp -r web/build/dist/* $APP_DIR/
cp server/build/libs/server-*.jar $SERVER_DIR/mebeatme-server.jar

# Create systemd service
echo "⚙️ Creating systemd service..."
cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=MeBeatMe Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$SERVER_DIR
ExecStart=/usr/bin/java -jar $SERVER_DIR/mebeatme-server.jar
Restart=always
RestartSec=10
Environment=SERVER_PORT=8080
Environment=SERVER_HOST=0.0.0.0
Environment=CORS_ORIGINS=https://${FULL_DOMAIN},https://${DOMAIN}
Environment=LOG_LEVEL=INFO

[Install]
WantedBy=multi-user.target
EOF

# Install nginx configuration
echo "🌐 Installing nginx configuration..."
cp deployment/nginx-mebeatme.conf $NGINX_CONFIG
ln -sf $NGINX_CONFIG $NGINX_ENABLED

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
nginx -t

# Reload nginx
echo "🔄 Reloading nginx..."
systemctl reload nginx

# Enable and start service
echo "🚀 Starting MeBeatMe service..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# Check service status
echo "📊 Checking service status..."
systemctl status $SERVICE_NAME --no-pager

# Test endpoints
echo "🧪 Testing endpoints..."
sleep 5  # Wait for service to start

# Test health endpoint
if curl -f "http://localhost:8080/health" > /dev/null 2>&1; then
    echo "✅ Health endpoint is working"
else
    echo "❌ Health endpoint failed"
    exit 1
fi

# Test API endpoint
if curl -f "http://localhost:8080/api/v1/sync/bests" > /dev/null 2>&1; then
    echo "✅ API endpoint is working"
else
    echo "❌ API endpoint failed"
    exit 1
fi

echo "🎉 MeBeatMe successfully deployed to ${FULL_DOMAIN}!"
echo ""
echo "📋 Next steps:"
echo "1. Configure DNS: Add A record for ${FULL_DOMAIN} pointing to this server"
echo "2. Install SSL certificate: certbot --nginx -d ${FULL_DOMAIN}"
echo "3. Test the deployment: https://${FULL_DOMAIN}"
echo "4. Monitor logs: journalctl -u ${SERVICE_NAME} -f"
echo ""
echo "🔗 URLs:"
echo "   Web Dashboard: https://${FULL_DOMAIN}"
echo "   API Health: https://${FULL_DOMAIN}/health"
echo "   API Bests: https://${FULL_DOMAIN}/api/v1/sync/bests"
