#!/bin/bash
# 4-amdir.sh - DNS Slave (Amdir)
set -euo pipefail

DOMAIN="k46"
TLD="com"
MASTER_IP="192.234.4.12"
SLAVE_IP="192.234.4.13"
FORWARDER="192.234.5.10"   # Minastir

echo "[1/5] Install bind9..."
apt-get update -y
apt-get install -y bind9 bind9utils bind9-doc dnsutils

echo "[2/5] named.conf.options (forwarder -> Minastir)..."
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    forwarders { ${FORWARDER}; };
    allow-query { any; };
    recursion yes;
    listen-on { any; };
};
EOF

echo "[3/5] named.conf.local (slave zone config)..."
cat > /etc/bind/named.conf.local <<EOF
zone "${DOMAIN}.${TLD}" {
    type slave;
    masters { ${MASTER_IP}; };
    file "/var/lib/bind/db.${DOMAIN}.${TLD}";
};
EOF

echo "[4/5] Pastikan resolver lokal dan start named (non-systemd)..."
rm -f /etc/resolv.conf || true
echo "nameserver 127.0.0.1" > /etc/resolv.conf

# pastikan direktori tujuan ada
mkdir -p /var/lib/bind
chown bind:bind /var/lib/bind || true

pkill named 2>/dev/null || true
/usr/sbin/named -f -g &>/var/log/named-amdir.log &

sleep 3
echo "[5/5] Slave Amdir siap. Memantau transfer zona dari master..."
echo "Periksa file slave: ls -l /var/lib/bind/db.${DOMAIN}.${TLD}"
ls -l /var/lib/bind/db.${DOMAIN}.${TLD} || echo "Belum ada file zona (slave akan menarik dari master otomatis jika master reachable & allow-transfer diaktifkan)."

echo
echo "Verifikasi:\n - di Amdir: dig SOA ${DOMAIN}.${TLD} @127.0.0.1\n - di Amdir (AXFR test dari master): dig @${MASTER_IP} ${DOMAIN}.${TLD} AXFR"
dig SOA ${DOMAIN}.${TLD} @127.0.0.1 +noall +answer || true
echo
echo "Jika transfer belum terjadi, pastikan master (Erendis) reachable dari Amdir: ping ${MASTER_IP}"
