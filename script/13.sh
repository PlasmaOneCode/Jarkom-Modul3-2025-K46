#!/bin/bash
# Jalankan di Galadriel, Celeborn, Oropher
set -euo pipefail

HOST=$(hostname)

case $HOST in
    Galadriel) PORT=8004 ;;
    Celeborn) PORT=8005 ;;
    Oropher) PORT=8006 ;;
    *) echo "Unknown host: $HOST"; exit 1 ;;
esac

# Konfigurasi Nginx untuk meneruskan .php ke PHP-FPM
cat > /etc/nginx/sites-available/php-worker <<EOF
server {
    listen $PORT;
    server_name ${HOST,,}.k46.com;
    root /var/www/html;
    index index.php index.html;

    # Blokir akses via IP
    if (\$host !~* ^${HOST,,}\.k46\.com$) {
        return 444;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Meneruskan permintaan .php ke PHP-FPM socket
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/

# Testing dan restart Nginx
nginx -t
service nginx restart

echo ""
echo "Test"
echo "  curl http://${HOST,,}.k46.com:$PORT"
echo ""
