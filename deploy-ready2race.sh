#!/bin/bash
# MeBeatMe Production Deployment Script for ready2race.run
# This script deploys MeBeatMe as a subdomain under ready2race.run

set -e

# Configuration
DOMAIN="ready2race.run"
SUBDOMAIN="mebeatme"
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
APP_DIR="/var/www/mebeatme"
SERVER_DIR="/opt/mebeatme"
NGINX_CONFIG="/etc/nginx/sites-available/mebeatme.ready2race.run"
NGINX_ENABLED="/etc/nginx/sites-enabled/mebeatme.ready2race.run"
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

# Copy dashboard files
echo "📦 Copying dashboard files..."
cp dashboard.html $APP_DIR/
cp fit-upload.html $APP_DIR/
cp manual-input.html $APP_DIR/

# Compile and copy production server
echo "🔨 Compiling production server..."
javac ProductionHttpServer.java
cp ProductionHttpServer.class $SERVER_DIR/

# Create systemd service
echo "⚙️ Creating systemd service..."
cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=MeBeatMe Production Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$SERVER_DIR
ExecStart=/usr/bin/java ProductionHttpServer
Restart=always
RestartSec=10
Environment=FULL_DOMAIN=${FULL_DOMAIN}
Environment=CORS_ORIGINS=https://${FULL_DOMAIN},https://${DOMAIN}
Environment=SERVER_PORT=8080
Environment=SERVER_HOST=0.0.0.0
Environment=LOG_LEVEL=INFO

[Install]
WantedBy=multi-user.target
EOF

# Install nginx configuration
echo "🌐 Installing nginx configuration..."
cat > $NGINX_CONFIG << EOF
server {
    listen 80;
    server_name ${FULL_DOMAIN};
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${FULL_DOMAIN};
    
    # SSL configuration (will be updated by certbot)
    ssl_certificate /etc/ssl/certs/${FULL_DOMAIN}.crt;
    ssl_certificate_key /etc/ssl/private/${FULL_DOMAIN}.key;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Serve static files
    location / {
        root $APP_DIR;
        index dashboard.html;
        try_files \$uri \$uri/ =404;
    }
    
    # Proxy API requests to Java server
    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
        
        # Handle preflight requests
        if (\$request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, POST, DELETE, OPTIONS";
            add_header Access-Control-Allow-Headers "Content-Type, Authorization";
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type 'text/plain charset=UTF-8';
            add_header Content-Length 0;
            return 204;
        }
    }
    
    # Proxy sync endpoints
    location /sync/ {
        proxy_pass http://localhost:8080/sync/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
    }
    
    # Proxy Strava endpoints
    location /strava/ {
        proxy_pass http://localhost:8080/strava/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://localhost:8080/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # File uploads
    location /uploads/ {
        alias /var/uploads/mebeatme/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Logging
    access_log /var/log/nginx/${FULL_DOMAIN}.access.log;
    error_log /var/log/nginx/${FULL_DOMAIN}.error.log;
}
EOF

# Enable nginx site
echo "🔗 Enabling nginx site..."
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

echo ""
echo "✅ MeBeatMe successfully deployed to ${FULL_DOMAIN}!"
echo ""
echo "🌐 URLs:"
echo "   Dashboard: https://${FULL_DOMAIN}/"
echo "   Health: https://${FULL_DOMAIN}/health"
echo "   API: https://${FULL_DOMAIN}/api/"
echo ""
echo "🔧 Management:"
echo "   Service: systemctl status ${SERVICE_NAME}"
echo "   Logs: journalctl -u ${SERVICE_NAME} -f"
echo "   Nginx: systemctl status nginx"
echo ""
echo "🔒 SSL Certificate:"
echo "   Run: sudo certbot --nginx -d ${FULL_DOMAIN}"
echo ""
echo "📋 Next Steps:"
echo "   1. Configure DNS: Add A record for ${SUBDOMAIN} pointing to this server"
echo "   2. Get SSL certificate: sudo certbot --nginx -d ${FULL_DOMAIN}"
echo "   3. Update Strava OAuth: Set callback URL to https://${FULL_DOMAIN}/dashboard.html"
echo "   4. Test deployment: curl https://${FULL_DOMAIN}/health"
echo ""
echo "🎉 Deployment complete!"
