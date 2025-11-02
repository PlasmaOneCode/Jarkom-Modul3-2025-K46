#!/bin/bash
# Jalankan di Elros dan Pharazon
set -euo pipefail

HOST=$(hostname)

if [ "$HOST" = "Elros" ]; then
    
    cat > /etc/nginx/sites-available/laravel-lb <<'EOF'
# Rate Limiting Zone - 10 requests per second
limit_req_zone $binary_remote_addr zone=laravel_limit:10m rate=10r/s;

upstream kesatria_numenor {
    server 192.234.1.11:8001 weight=3;
    server 192.234.1.12:8002 weight=1;
    server 192.234.1.13:8003 weight=1;
}

server {
    listen 80;
    server_name elros.k46.com;

    if ($host !~* ^elros\.k46\.com$) {
        return 444;
    }

    # Apply rate limiting
    limit_req zone=laravel_limit burst=20 nodelay;
    limit_req_status 429;

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
    
elif [ "$HOST" = "Pharazon" ]; then
    
    cat > /etc/nginx/sites-available/php-lb <<'EOF'
# Rate Limiting Zone - 10 requests per second
limit_req_zone $binary_remote_addr zone=php_limit:10m rate=10r/s;

upstream kesatria_lorien {
    server 192.234.2.21:8004;
    server 192.234.2.22:8005;
    server 192.234.2.23:8006;
}

server {
    listen 80;
    server_name pharazon.k46.com;

    if ($host !~* ^pharazon\.k46\.com$) {
        return 444;
    }

    # Apply rate limiting
    limit_req zone=php_limit burst=20 nodelay;
    limit_req_status 429;

    location / {
        proxy_pass http://kesatria_lorien;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
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
    
    nginx -t && service nginx restart

else
    echo "Script dijalankan di Elros atau Pharazon"
    exit 1
fi

echo ""
echo "Test Elros (Laravel):"
echo "  ab -n 500 -c 100 http://elros.k46.com/api/airing"
echo ""
echo "Test Pharazon (PHP):"
echo "  ab -n 500 -c 100 -A noldor:silvan http://pharazon.k46.com/"
echo ""
echo "Monitor log untuk request yang ditolak (429):"
echo "  tail -f /var/log/nginx/elros_error.log | grep limiting"
echo "  tail -f /var/log/nginx/pharazon_error.log | grep limiting"
echo ""