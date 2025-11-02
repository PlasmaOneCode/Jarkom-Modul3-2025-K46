#!/bin/bash
# Jalankan di Pharazon
set -euo pipefail

apt-get update -y
apt-get install -y nginx

# Konfigurasi Nginx sebagai Reverse Proxy untuk PHP
cat > /etc/nginx/sites-available/php-lb <<'EOF'
upstream kesatria_lorien {
    server 192.234.2.21:8004;  # Galadriel
    server 192.234.2.22:8005;  # Celeborn
    server 192.234.2.23:8006;  # Oropher
}

server {
    listen 80;
    server_name pharazon.k46.com;

    if ($host !~* ^pharazon\.k46\.com$) {
        return 444;
    }

    location / {
        proxy_pass http://kesatria_lorien;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # SOAL 16: Forward Basic Authentication ke worker
        proxy_set_header Authorization $http_authorization;
        proxy_pass_header Authorization;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    access_log /var/log/nginx/pharazon_access.log;
    error_log /var/log/nginx/pharazon_error.log;
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/php-lb /etc/nginx/sites-enabled/

# Testing dan restart Nginx
nginx -t
service nginx restart

echo ""
echo "Test"
echo "curl -u noldor:silvan http://pharazon.k46.com"
echo ""