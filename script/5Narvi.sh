#!/bin/bash
# 5Narvi.sh - Konfigurasi Database Slave
DB_PASS="arda123"
MASTER_IP="192.234.3.12"

apt update -y
apt install -y mariadb-server
cat >> /etc/mysql/mariadb.conf.d/50-server.cnf <<EOF

[mysqld]
server-id=2
relay-log=/var/log/mysql/mysql-relay-bin.log
EOF
systemctl restart mariadb

mysql -u root <<EOF
CHANGE MASTER TO MASTER_HOST='${MASTER_IP}', MASTER_USER='repl', MASTER_PASSWORD='${DB_PASS}', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=4;
START SLAVE;
EOF

echo "[✓] Narvi menjadi Database Slave dari Palantir."
