#!/bin/bash
# Jalankan di Elros
set -euo pipefail

cat > /etc/nginx/sites-available/laravel-lb <<'EOF'
upstream kesatria_numenor {
    server 192.234.1.11:8001 weight=3;  # Elendil - 60%
    server 192.234.1.12:8002 weight=1;  # Isildur - 20%
    server 192.234.1.13:8003 weight=1;  # Anarion - 20%
}

server {
    listen 80;
    server_name elros.k46.com;

    if ($host !~* ^elros\.k46\.com$) {
        return 444;
    }

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    access_log /var/log/nginx/elros_access.log;
    error_log /var/log/nginx/elros_error.log;
}
EOF

nginx -t && service nginx restart

echo "Tes"
echo "ab -n 2000 -c 100 http://elros.k46.com/api/airing"
echo ""
