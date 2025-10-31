#!/bin/bash
# 5.sh - Konfigurasi Database Master (Palantir) dan Slave (Narvi)
DB_PASS="arda123"

echo "[1/5] Instalasi MariaDB..."
apt update -y
apt install -y mariadb-server

echo "[2/5] Mengatur konfigurasi Palantir (Master)..."
cat >> /etc/mysql/mariadb.conf.d/50-server.cnf <<EOF

[mysqld]
server-id=1
log_bin=/var/log/mysql/mysql-bin.log
bind-address=0.0.0.0
EOF
systemctl restart mariadb

echo "[3/5] Membuat user replikasi..."
mysql -u root <<EOF
CREATE USER 'repl'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
EOF

echo "[4/5] Exporting data..."
mysqldump -u root --all-databases --master-data > /root/dbdump.sql
echo "[✓] Palantir siap menjadi Database Master."
