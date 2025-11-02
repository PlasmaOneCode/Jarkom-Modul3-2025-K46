#!/bin/bash
# 2Aldarion.sh — DHCP Server setup (K-46)
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan script ini sebagai root (sudo)."
  exit 1
fi

echo "[*] Menginstal isc-dhcp-server..."
apt-get update -y
apt-get install -y isc-dhcp-server

echo "[*] Backup file konfigurasi lama..."
cp -n /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup.$(date +%s) || true

echo "[*] Menulis konfigurasi baru ke /etc/dhcp/dhcpd.conf..."

cat > /etc/dhcp/dhcpd.conf <<'EOF'
# === DHCP SERVER K46 ===
ddns-update-style none;
option domain-name "numenor.lab";
option domain-name-servers 192.234.5.10;  # Minastir sebagai DNS Forwarder
default-lease-time 600;
max-lease-time 3600;
authoritative;

# ==============================
# Subnet untuk Keluarga Manusia
# ==============================
subnet 192.234.1.0 netmask 255.255.255.0 {
    range 192.234.1.6 192.234.1.34;
    range 192.234.1.68 192.234.1.94;
    option routers 192.234.1.1;
    option broadcast-address 192.234.1.255;
    option domain-name-servers 192.234.5.10;
    default-lease-time 1800;
    max-lease-time 3600;
}

# ===========================
# Subnet untuk Keluarga Peri
# ===========================
subnet 192.234.2.0 netmask 255.255.255.0 {
    range 192.234.2.35 192.234.2.67;
    range 192.234.2.96 192.234.2.121;
    option routers 192.234.2.1;
    option broadcast-address 192.234.2.255;
    option domain-name-servers 192.234.5.10;
    default-lease-time 600;
    max-lease-time 3600;
}

# ==========================
# Subnet internal Aldarion
# ==========================
subnet 192.234.3.0 netmask 255.255.255.0 {
    option routers 192.234.3.1;
    option broadcast-address 192.234.3.255;
    option domain-name-servers 192.234.5.10;
}

# ======================
# Subnet tambahan lainnya
# ======================
subnet 192.234.4.0 netmask 255.255.255.0 {
    option routers 192.234.4.1;
    option broadcast-address 192.234.4.255;
    option domain-name-servers 192.234.5.10;
}

# ========================
# Fixed address untuk Khamul
# ========================
host khamul {
    hardware ethernet 02:42:ac:11:00:01;  # Ganti MAC sesuai hasil "ip link show eth0" di Khamul
    fixed-address 192.234.3.95;
    option routers 192.234.3.1;
    option domain-name-servers 192.234.5.10;
}
EOF

echo "[*] Mengatur agar DHCP Server aktif di interface Aldarion (eth0)..."
cat > /etc/default/isc-dhcp-server <<'EOF'
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

echo "[*] Mengaktifkan layanan isc-dhcp-server..."
service isc-dhcp-server restart || /usr/sbin/dhcpd -4 -f -d eth0 &

echo "[✓] DHCP Server Aldarion telah dikonfigurasi."
echo "    Rentang IP:"
echo "      - Manusia: 192.234.1.6–34 dan 192.234.1.68–94"
echo "      - Peri:     192.234.2.35–67 dan 192.234.2.96–121"
echo "      - Khamul:   192.234.3.95 (fixed)"
echo ""
echo "Gunakan 'cat /var/lib/dhcp/dhcpd.leases' untuk memeriksa klien yang sudah mendapat IP."
