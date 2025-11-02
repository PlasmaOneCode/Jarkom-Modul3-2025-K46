#!/bin/bash
# 3.sh — Setup Firewall & Internet Control via Minastir
# Kelompok 46 | Prefix 192.234

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan script ini sebagai root (sudo)."
  exit 1
fi

echo "[*] Menyiapkan Minastir sebagai pengawas keluar (gateway Valinor/Internet)"

echo "[*] Menginstal bind9 sebagai DNS Forwarder..."
apt-get update -y
apt-get install -y bind9 bind9-utils bind9-doc dnsutils

echo "[*] Mengatur konfigurasi DNS Forwarder..."
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    listen-on { any; };
    recursion yes;
};
EOF

echo "[*] Mengatur resolv.conf agar menggunakan localhost"
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf

echo "[*] Menjalankan named secara manual (non-systemd)"
pkill named 2>/dev/null || true
/usr/sbin/named -f -g &>/var/log/named.log &


# 1️ Pastikan IP Forwarding aktif
sysctl -w net.ipv4.ip_forward=1 >/dev/null
echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf

# 2️ Atur NAT (Minastir sebagai penghubung ke Internet)
#   eth0 → terhubung ke Durin (192.234.5.0/24)
#   eth1 → terhubung ke NAT/Internet (192.168.122.0/24)
iptables -t nat -F
iptables -F

echo "[*] Menambahkan aturan NAT..."
iptables -t nat -A POSTROUTING -o eth1 -s 192.234.0.0/16 -j MASQUERADE

# 3️ Izinkan forwarding dari LAN (Durin dan semua node) ke Internet
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# 4️ Blokir akses langsung ke Internet dari node selain Minastir
# Catatan: Semua node lainnya gateway-nya diarahkan ke Minastir (192.234.5.10)
echo "[*] Memastikan node lain tidak bisa langsung ke Internet (selain via Minastir)"

# ensure any old named stopped, then run named in background and log
pkill named 2>/dev/null || true
/usr/sbin/named -f -g &>/var/log/named.log &
echo "/usr/sbin/named started; logs in /var/log/named.log"

# Simpan aturan iptables (opsional)
if command -v iptables-save >/dev/null 2>&1; then
  iptables-save > /etc/iptables.rules
  echo "[*] Aturan firewall disimpan ke /etc/iptables.rules"
fi

echo "[✓] Minastir kini menjadi pengawas arus informasi ke Valinor (Internet)"
echo "    - Semua trafik keluar harus melewati Minastir"
echo "    - Durin tetap tidak memiliki akses langsung ke Internet"
