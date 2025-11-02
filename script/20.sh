#!/bin/bash
# Jalankan di Pharazon
set -euo pipefail

mkdir -p /var/cache/nginx/pharazon
chown -R www-data:www-data /var/cache/nginx/pharazon

cat > /etc/nginx/sites-available/php-lb <<'EOF'
# Rate Limiting
limit_req_zone $binary_remote_addr zone=php_limit:10m rate=10r/s;

# Cache Path Configuration
proxy_cache_path /var/cache/nginx/pharazon 
    levels=1:2 
    keys_zone=pharazon_cache:10m 
    max_size=100m 
    inactive=60m 
    use_temp_path=off;

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

    # Rate Limiting
    limit_req zone=php_limit burst=20 nodelay;
    limit_req_status 429;

    location / {
        # Proxy Cache Settings
        proxy_cache pharazon_cache;
        proxy_cache_valid 200 5m;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_bypass $http_cache_control;
        add_header X-Cache-Status $upstream_cache_status;
        
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

echo ""
echo "Dari client, test cache status:"
echo ""
echo "1. Request pertama (MISS):"
echo "   curl -u noldor:silvan -I http://pharazon.k46.com"
echo "   # Lihat header: X-Cache-Status: MISS"
echo ""
echo "2. Request kedua (HIT):"
echo "   curl -u noldor:silvan -I http://pharazon.k46.com"
echo "   # Lihat header: X-Cache-Status: HIT"
echo ""
echo "3. Request ketiga (HIT):"
echo "   curl -u noldor:silvan -I http://pharazon.k46.com"
echo ""
echo "4. Benchmark untuk monitor cache hit rate:"
echo "   ab -n 1000 -c 50 -A noldor:silvan http://pharazon.k46.com/"
echo ""
echo "Monitor cache:"
echo "  tail -f /var/log/nginx/pharazon_access.log | grep -o 'X-Cache-Status: [A-Z]*'"
echo "  du -sh /var/cache/nginx/pharazon"
echo ""
