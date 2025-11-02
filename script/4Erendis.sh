#!/bin/bash
# 4-erendis.sh - DNS Master (Erendis)
set -euo pipefail

DOMAIN="k46"
TLD="com"
MASTER_IP="192.234.4.12"
SLAVE_IP="192.234.4.13"
FORWARDER="192.234.5.10"   # Minastir

SERIAL=$(date +%Y%m%d%H%M)

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

echo "[3/5] named.conf.local (master zone)..."
cat > /etc/bind/named.conf.local <<EOF
zone "${DOMAIN}.${TLD}" {
    type master;
    file "/etc/bind/db.${DOMAIN}.${TLD}";
    allow-transfer { ${SLAVE_IP}; };
    also-notify { ${SLAVE_IP}; };
};
EOF

echo "[4/5] Membuat file zone /etc/bind/db.${DOMAIN}.${TLD}..."
cat > /etc/bind/db.${DOMAIN}.${TLD} <<EOF
\$TTL    604800
@       IN      SOA     ns1.${DOMAIN}.${TLD}. root.${DOMAIN}.${TLD}. (
                        ${SERIAL} ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

; Name Servers
@       IN      NS      ns1.${DOMAIN}.${TLD}.
@       IN      NS      ns2.${DOMAIN}.${TLD}.
ns1     IN      A       ${MASTER_IP}
ns2     IN      A       ${SLAVE_IP}

; Important hosts (sesuaikan jika perlu)
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

echo "[5/5] Pastikan resolver lokal dan start named (non-systemd)..."
rm -f /etc/resolv.conf || true
echo "nameserver 127.0.0.1" > /etc/resolv.conf

pkill named 2>/dev/null || true
/usr/sbin/named -f -g &>/var/log/named-erendis.log &

sleep 2
echo "[✓] Erendis (master) siap."
echo "Verifikasi: dig SOA ${DOMAIN}.${TLD} @127.0.0.1"
dig SOA ${DOMAIN}.${TLD} @127.0.0.1 +noall +answer
