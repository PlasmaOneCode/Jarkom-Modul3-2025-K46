#!/bin/bash
# Part A: Jalankan di Palantir (Master)
# Part B: Jalankan di Narvi (Slave)
set -euo pipefail

DB_PASS="arda123"
MASTER_IP="192.234.3.12"
HOST=$(hostname)

if [ "$HOST" = "Palantir" ]; then
    
    apt-get update -y
    apt-get install -y mariadb-server
    
    cat >> /etc/mysql/mariadb.conf.d/50-server.cnf <<EOF

[mysqld]
server-id=1
log_bin=/var/log/mysql/mysql-bin.log
bind-address=0.0.0.0
EOF
    
    mkdir -p /var/log/mysql
    chown -R mysql:mysql /var/log/mysql
    chmod 750 /var/log/mysql
    
    service mariadb restart
    
    mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
EOF
    
    mysqldump -u root --all-databases --master-data > /root/dbdump.sql
    
    mysql -u root -e "SHOW MASTER STATUS;"
    
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS test_replication;
USE test_replication;
CREATE TABLE IF NOT EXISTS test_table (
    id INT PRIMARY KEY AUTO_INCREMENT,
    data VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO test_table (data) VALUES ('Data dari Master Palantir');
EOF
    
    echo ""
    echo "Transfer file ke Narvi:"
    echo "  scp /root/dbdump.sql root@narvi:/root/"
    echo ""
    echo "Catat MASTER_LOG_FILE dan MASTER_LOG_POS"
    echo "Lalu jalankan script ini di Narvi"

elif [ "$HOST" = "Narvi" ]; then
    
    apt-get update -y
    apt-get install -y mariadb-server
    
    cat >> /etc/mysql/mariadb.conf.d/50-server.cnf <<EOF

[mysqld]
server-id=2
relay-log=/var/log/mysql/mysql-relay-bin.log
bind-address=0.0.0.0
EOF
    
    mkdir -p /var/log/mysql
    chown -R mysql:mysql /var/log/mysql
    chmod 750 /var/log/mysql
    
    service mariadb restart
    
    if [ -f /root/dbdump.sql ]; then
        mysql -u root < /root/dbdump.sql
        echo "Data imported"
    else
        echo "WARNING: /root/dbdump.sql tidak ditemukan!"
        echo "Salin dari Palantir: scp root@palantir:/root/dbdump.sql /root/"
        exit 1
    fi
    
    read -p "MASTER_LOG_FILE (contoh: mysql-bin.000001): " LOG_FILE
    read -p "MASTER_LOG_POS (contoh: 328): " LOG_POS
    
    mysql -u root <<EOF
STOP SLAVE;
CHANGE MASTER TO 
    MASTER_HOST='${MASTER_IP}', 
    MASTER_USER='repl', 
    MASTER_PASSWORD='${DB_PASS}', 
    MASTER_LOG_FILE='${LOG_FILE}', 
    MASTER_LOG_POS=${LOG_POS};
START SLAVE;
EOF
    
    mysql -u root -e "SHOW SLAVE STATUS\G" | grep -E "Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master"
    
    mysql -u root -e "SELECT * FROM test_replication.test_table;"
    
    echo "Test"
    echo "Di Palantir, jalankan:"
    echo "  mysql -u root -e 'CREATE TABLE test_replication.worker_test (id INT, name VARCHAR(50));'"
    echo ""
    echo "Cek di Narvi:"
    echo "  mysql -u root -e 'SHOW TABLES FROM test_replication;'"
    
    echo ""

else
    echo "Script ini harus dijalankan di Palantir atau Narvi"
    exit 1
fi