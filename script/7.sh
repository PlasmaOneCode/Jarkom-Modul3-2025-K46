#!/bin/bash
# 7.sh - Load Balancer PHP (Pharazon)
apt update -y
apt install -y nginx

cat > /etc/nginx/sites-available/php-lb <<EOF
upstream php_cluster {
    server 192.234.2.21;
    server 192.234.2.22;
    server 192.234.2.23;
}

server {
    listen 80;
    server_name pharazon.k46.com;

    location / {
        proxy_pass http://php_cluster;
    }
}
EOF

ln -s /etc/nginx/sites-available/php-lb /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
echo "[✓] Pharazon berfungsi sebagai Load Balancer PHP."
