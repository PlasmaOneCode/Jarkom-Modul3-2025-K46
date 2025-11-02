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

# Buat htpasswd dengan user: noldor, pass: silvan
htpasswd -bc /etc/nginx/.htpasswd noldor silvan

# Update konfigurasi Nginx dengan Basic Auth
cat > /etc/nginx/sites-available/php-worker <<EOF
server {
    listen $PORT;
    server_name ${HOST,,}.k46.com;
    root /var/www/html;
    index index.php index.html;

    if (\$host !~* ^${HOST,,}\.k46\.com$) {
        return 444;
    }

    # Basic HTTP Authentication
    auth_basic "Taman Peri K46 - Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files \$uri \$uri/ =404;
    }

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

nginx -t && service nginx restart

echo ""
echo "Test"
echo "  curl -u noldor:silvan http://${HOST,,}.k46.com:$PORT"
echo ""