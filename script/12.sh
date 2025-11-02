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

# Install Nginx dan PHP8.4-FPM
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx \
    php8.4-fpm \
    apache2-utils

# Buat file index.php yang menampilkan hostname
mkdir -p /var/www/html
cat > /var/www/html/index.php <<'PHPEOF'
<?php
$hostname = gethostname();
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
    </style>
</head>
<body>
    <div class="container">
        <h1>Taman Peri K46</h1>
        <h2>Hostname: <?php echo $hostname; ?></h2>
        <p>Server Time: <?php echo date('Y-m-d H:i:s'); ?></p>
        <p>PHP Version: <?php echo phpversion(); ?></p>
    </div>
</body>
</html>
PHPEOF

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[3/3] Set permissions..."
service php8.4-fpm start
