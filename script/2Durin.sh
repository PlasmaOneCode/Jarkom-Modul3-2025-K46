#!/bin/bash
# 2Durin.sh — DHCP Relay setup (K-46)
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan script ini sebagai root (sudo)."
  exit 1
fi

echo "[*] Menginstal isc-dhcp-relay..."
apt-get update -y
apt-get install -y isc-dhcp-relay

echo "[*] Menulis konfigurasi ke /etc/default/isc-dhcp-relay"

cat > /etc/default/isc-dhcp-relay <<'EOF'
# DHCP Server tujuan (Aldarion di subnet 192.234.3.0/24)
SERVERS="192.234.3.13"

# Interface yang menerima permintaan DHCP (dari subnet dynamic)
# eth1 = Human (192.234.1.0/24)
# eth2 = Elf (192.234.2.0/24)
INTERFACES="eth1 eth2"

# Opsi tambahan (-a agar menyertakan alamat relay)
OPTIONS="-a"
EOF

echo "[*] Mengaktifkan layanan isc-dhcp-relay..."
pkill dhcrelay 2>/dev/null || true
/usr/sbin/dhcrelay -q -a -i eth1 -i eth2 192.234.3.13 &
service isc-dhcp-relay restart || /usr/sbin/dhcrelay -4 -d 192.234.3.13 eth1 eth2 &

echo "[✓] DHCP Relay Durin telah dikonfigurasi dan berjalan."
echo "    Durin kini meneruskan permintaan DHCP dari eth1 & eth2 ke Aldarion (192.234.3.13)"
