#!/bin/bash
# 6.sh - Load Balancer Laravel (Elros)
apt update -y
apt install -y nginx

cat > /etc/nginx/sites-available/laravel-lb <<EOF
upstream laravel_cluster {
    server 192.234.1.11;
    server 192.234.1.12;
    server 192.234.1.13;
}

server {
    listen 80;
    server_name elros.k46.com;

    location / {
        proxy_pass http://laravel_cluster;
    }
}
EOF

ln -s /etc/nginx/sites-available/laravel-lb /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
echo "[✓] Elros berfungsi sebagai Load Balancer Laravel."
