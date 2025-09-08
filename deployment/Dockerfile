# MeBeatMe Docker Configuration for Subdomain Deployment
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy application files
COPY server/build/libs/server-*.jar /app/mebeatme-server.jar
COPY web/build/dist/ /var/www/mebeatme/
COPY deployment/nginx-mebeatme.conf /etc/nginx/sites-available/mebeatme.ready2race.me

# Create directories
RUN mkdir -p /var/uploads/mebeatme && \
    mkdir -p /var/log/mebeatme && \
    chown -R www-data:www-data /var/www/mebeatme && \
    chown -R www-data:www-data /var/uploads/mebeatme

# Enable nginx site
RUN ln -sf /etc/nginx/sites-available/mebeatme.ready2race.me /etc/nginx/sites-enabled/ && \
    rm -f /etc/nginx/sites-enabled/default

# Create startup script
RUN echo '#!/bin/bash\n\
# Start nginx\n\
nginx\n\
\n\
# Start MeBeatMe server\n\
java -jar /app/mebeatme-server.jar &\n\
\n\
# Wait for any process to exit\n\
wait -n\n\
\n\
# Exit with status of process that exited first\n\
exit $?' > /app/start.sh && \
    chmod +x /app/start.sh

# Expose ports
EXPOSE 80 443 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start both services
CMD ["/app/start.sh"]
