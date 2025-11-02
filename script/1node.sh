# Minastir — DNS Forwarder — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.5.10
    netmask 255.255.255.0
    gateway 192.234.5.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Aldarion — DHCP Server — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.3.13
    netmask 255.255.255.0
    gateway 192.234.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Erendis — DNS Master — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.4.12
    netmask 255.255.255.0
    gateway 192.234.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Amdir — DNS Slave — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.4.13
    netmask 255.255.255.0
    gateway 192.234.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Palantir — Database Server — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.3.12
    netmask 255.255.255.0
    gateway 192.234.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Narvi — Database Slave — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.3.14
    netmask 255.255.255.0
    gateway 192.234.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Elros — Load Balancer (Laravel) — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.1.16
    netmask 255.255.255.0
    gateway 192.234.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Pharazon — Load Balancer (PHP) — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.2.13
    netmask 255.255.255.0
    gateway 192.234.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Elendil — Laravel Worker-1 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.1.11
    netmask 255.255.255.0
    gateway 192.234.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Isildur — Laravel Worker-2 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.1.12
    netmask 255.255.255.0
    gateway 192.234.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Anarion — Laravel Worker-3 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.1.13
    netmask 255.255.255.0
    gateway 192.234.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Galadriel — PHP Worker-1 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.2.21
    netmask 255.255.255.0
    gateway 192.234.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Celeborn — PHP Worker-2 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.2.22
    netmask 255.255.255.0
    gateway 192.234.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Oropher — PHP Worker-3 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.2.23
    netmask 255.255.255.0
    gateway 192.234.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Miriel — Client-Static-1 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.1.14
    netmask 255.255.255.0
    gateway 192.234.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Celebrimbor — Client-Static-2 — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.2.12
    netmask 255.255.255.0
    gateway 192.234.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Gilgalad — Client-Dynamic-1 (DHCP) — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf


# (Jangan set static di sini — klien ini harus mendapatkan IP via Aldarion)

# Amandil — Client-Dynamic-2 (DHCP) — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf


# (Jangan set static di sini — klien ini harus mendapatkan IP via Aldarion)

# Khamul — Client-Fixed-Address — nevarre/gns3-debi:new
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.234.4.11
    netmask 255.255.255.0
    gateway 192.234.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Jangan lupa ping 192.168.122.1 di setiap node!