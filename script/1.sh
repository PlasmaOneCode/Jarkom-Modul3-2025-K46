#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan script ini sebagai root (sudo)."
  exit 1
fi

HOST="$(hostname)"
echo "[*] Running 1.sh on host: $HOST"

# --- network interfaces (tulis seperti sebelumnya) ---
cat > /etc/network/interfaces <<'EOF'
# Durin router (WAN to NAT + 5 LANs) - generated for K46
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

auto eth1
iface eth1 inet static
    address 192.234.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.234.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.234.4.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.234.3.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 192.234.5.1
    netmask 255.255.255.0
EOF

echo "[*] Wrote /etc/network/interfaces"

# Apply immediate IPs
for IF in eth1 eth2 eth3 eth4 eth5; do
  case $IF in
    eth1) IP="192.234.1.1/24" ;;
    eth2) IP="192.234.2.1/24" ;;
    eth3) IP="192.234.4.1/24" ;;
    eth4) IP="192.234.3.1/24" ;;
    eth5) IP="192.234.5.1/24" ;;
  esac
  ip addr replace $IP dev $IF || echo "warning: failed to set $IF $IP"
  ip link set dev $IF up || true
done
ip link set lo up || true

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1 >/dev/null

# Clear previous iptables NAT/FW rules we will recreate (safeguard)
iptables -t nat -F || true
iptables -F || true

# NAT: allow LANs 192.234.0.0/16 to be masqueraded out via eth0
iptables -t nat -A POSTROUTING -o eth0 -s 192.234.0.0/16 -j MASQUERADE

# --- SECURITY POLICY: force all non-Durin traffic to go via Minastir ---
# Minastir IP (static per soal)
MINASTIR=192.234.5.10

# Allow established/related (keep this)
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow forwarding from Minastir to Internet (eth0)
iptables -A FORWARD -s $MINASTIR -o eth0 -j ACCEPT

# Block any other forwarded packet going out eth0 (force proxy)
# iptables -A FORWARD -o eth0 -j REJECT

# Allow LAN internal forwarding (LAN <-> LAN) so internal comm works
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT || true
iptables -A FORWARD -i eth1 -o eth3 -j ACCEPT || true
iptables -A FORWARD -i eth1 -o eth4 -j ACCEPT || true
iptables -A FORWARD -i eth1 -o eth5 -j ACCEPT || true
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT || true
iptables -A FORWARD -i eth2 -o eth3 -j ACCEPT || true
iptables -A FORWARD -i eth2 -o eth4 -j ACCEPT || true
iptables -A FORWARD -i eth2 -o eth5 -j ACCEPT || true
iptables -A FORWARD -i eth3 -o eth1 -j ACCEPT || true
iptables -A FORWARD -i eth3 -o eth2 -j ACCEPT || true
iptables -A FORWARD -i eth3 -o eth4 -j ACCEPT || true
iptables -A FORWARD -i eth3 -o eth5 -j ACCEPT || true
iptables -A FORWARD -i eth4 -o eth1 -j ACCEPT || true
iptables -A FORWARD -i eth4 -o eth2 -j ACCEPT || true
iptables -A FORWARD -i eth4 -o eth3 -j ACCEPT || true
iptables -A FORWARD -i eth4 -o eth5 -j ACCEPT || true
iptables -A FORWARD -i eth5 -o eth1 -j ACCEPT || true
iptables -A FORWARD -i eth5 -o eth2 -j ACCEPT || true
iptables -A FORWARD -i eth5 -o eth3 -j ACCEPT || true
iptables -A FORWARD -i eth5 -o eth4 -j ACCEPT || true

# Block Durin's own outgoing connections to Internet (so router tidak bisa pakai nameserver NAT)
# iptables -A OUTPUT -o eth0 -j DROP
iptables -A INPUT -p udp --dport 67:68 -j ACCEPT

# Save iptables snapshot
if command -v iptables-save >/dev/null 2>&1; then
  iptables-save > /etc/iptables.rules || true
  echo "[*] iptables saved to /etc/iptables.rules"
fi

# Install and configure DHCP relay (forward DHCP requests for eth1,eth2 to Aldarion)
DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay

# Configure relay: server Aldarion (DHCP server) assumed at 192.234.3.13
cat > /etc/default/isc-dhcp-relay <<EOF
# /etc/default/isc-dhcp-relay - generated
SERVERS="192.234.3.13"
INTERFACES="eth1 eth2"
OPTIONS=""
EOF

systemctl restart isc-dhcp-relay || true
systemctl enable isc-dhcp-relay >/dev/null 2>&1 || true

echo "[*] Durin setup done. Re-check: ip addr, ip route, iptables -L -t nat -v"
