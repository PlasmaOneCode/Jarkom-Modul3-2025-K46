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

# Update konfigurasi Nginx dengan X-Real-IP
cat > /etc/nginx/sites-available/php-worker <<EOF
server {
    listen $PORT;
    server_name ${HOST,,}.k46.com;
    root /var/www/html;
    index index.php index.html;

    if (\$host !~* ^${HOST,,}\.k46\.com$) {
        return 444;
    }

    auth_basic "Taman Peri K46 - Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        
        # Pass X-Real-IP ke PHP
        fastcgi_param HTTP_X_REAL_IP \$remote_addr;
        
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

nginx -t && service nginx restart

# Update index.php untuk menampilkan IP pengunjung
cat > /var/www/html/index.php <<'PHPEOF'
<?php
// Ambil IP pengunjung dari X-Real-IP header
$hostname = gethostname();
$real_ip = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'];
?>
<!DOCTYPE html>
<html>
<head>
    <title>Taman Peri K46 - <?php echo $hostname; ?></title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
        }
        h1 { margin-top: 0; }
        .info {
            background: rgba(0, 0, 0, 0.2);
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Taman Peri K46</h1>
        <div class="info">
            <h2>Hostname: <?php echo $hostname; ?></h2>
            <p><strong>IP Pengunjung (Real IP):</strong> <?php echo $real_ip; ?></p>
            <p><strong>Server Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
            <p><strong>PHP Version:</strong> <?php echo phpversion(); ?></p>
        </div>
    </div>
</body>
</html>
PHPEOF

echo ""
echo "Test"
echo "curl -u noldor:silvan http://${HOST,,}.k46.com:$PORT"
echo ""