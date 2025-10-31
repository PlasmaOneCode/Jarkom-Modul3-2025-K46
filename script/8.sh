#!/bin/bash
# 8.sh - Laravel Worker setup
apt update -y
apt install -y apache2 php php-mysql git unzip

cd /var/www
git clone https://github.com/laravel/laravel.git project
cd project
composer install

chown -R www-data:www-data /var/www/project
systemctl enable apache2
systemctl restart apache2
echo "[✓] Laravel Worker aktif."
