#!/bin/bash
# 9.sh - PHP Worker setup
apt update -y
apt install -y apache2 php

echo "<?php echo 'Halo dari ' . gethostname(); ?>" > /var/www/html/index.php
systemctl enable apache2
systemctl restart apache2
echo "[✓] PHP Worker siap."
