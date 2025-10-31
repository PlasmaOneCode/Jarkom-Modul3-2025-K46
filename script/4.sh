#!/bin/bash
# =====================================================
# 4.sh - Konfigurasi DNS Master (Erendis) dan Slave (Amdir)
# =====================================================

DOMAIN="arda"
TLD="com"
MASTER_IP="192.234.4.12"
SLAVE_IP="192.234.4.13"

echo "[1/7] Menginstal bind9 di Erendis (DNS Master)..."
apt update -y
apt install -y bind9 bind9utils bind9-doc

echo "[2/7] Mengatur named.conf.options..."
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    forwarders {
        192.234.5.10;  // Minastir (DNS Forwarder)
    };
    allow-query { any; };
    recursion yes;
    listen-on { any; };
};
EOF

echo "[3/7] Menyiapkan zona domain ${DOMAIN}.${TLD}..."
cat > /etc/bind/named.conf.local <<EOF
zone "${DOMAIN}.${TLD}" {
    type master;
    file "/etc/bind/db.${DOMAIN}.${TLD}";
    allow-transfer { ${SLAVE_IP}; };
    also-notify { ${SLAVE_IP}; };
};
EOF

echo "[4/7] Membuat file zona untuk ${DOMAIN}.${TLD}..."
cat > /etc/bind/db.${DOMAIN}.${TLD} <<EOF
\$TTL    604800
@       IN      SOA     ns1.${DOMAIN}.${TLD}. root.${DOMAIN}.${TLD}. (
                        2025103101 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

; Name Servers
@       IN      NS      ns1.${DOMAIN}.${TLD}.
@       IN      NS      ns2.${DOMAIN}.${TLD}.
ns1     IN      A       ${MASTER_IP}
ns2     IN      A       ${SLAVE_IP}

; Important hosts
palantir    IN  A   192.234.3.12
elros       IN  A   192.234.1.16
pharazon    IN  A   192.234.2.13
elendil     IN  A   192.234.1.11
isildur     IN  A   192.234.1.12
anarion     IN  A   192.234.1.13
galadriel   IN  A   192.234.2.21
celeborn    IN  A   192.234.2.22
oropher     IN  A   192.234.2.23
EOF

echo "[5/7] Mengatur resolv.conf untuk menggunakan localhost..."
echo "nameserver 127.0.0.1" > /etc/resolv.conf

echo "[6/7] Menyalin konfigurasi ke Amdir (Slave DNS)..."
# Pastikan Erendis dapat ssh ke Amdir tanpa password
scp -o StrictHostKeyChecking=no /etc/bind/named.conf.local root@${SLAVE_IP}:/etc/bind/
scp -o StrictHostKeyChecking=no /etc/bind/db.${DOMAIN}.${TLD} root@${SLAVE_IP}:/etc/bind/

echo "[7/7] Menjalankan ulang BIND9..."
pkill named 2>/dev/null
named -f -g &

echo "[✓] DNS Master Erendis telah dikonfigurasi."
echo "    Domain  : ${DOMAIN}.${TLD}"
echo "    Master  : ns1.${DOMAIN}.${TLD} (${MASTER_IP})"
echo "    Slave   : ns2.${DOMAIN}.${TLD} (${SLAVE_IP})"
echo
echo "Sekarang, jalankan konfigurasi slave di Amdir."

# di amdir ls /var/lib/bind/ Harus muncul file db.arda.com.
# Uji dari node lain (misalnya Palantir):

# dig palantir.arda.com @192.234.4.12
# dig isildur.arda.com @192.234.4.13