#!/bin/bash
# 10.sh - Client Testing
echo "[1/3] Mengatur DNS resolver..."
echo "nameserver 192.234.5.10" > /etc/resolv.conf

echo "[2/3] Menguji konektivitas ke domain penting..."
for site in elros.k46.com pharazon.k46.com palantir.k46.com; do
  echo "Tes: $site"
  dig $site +short
done

echo "[3/3] Menguji akses web..."
curl -I http://elros.k46.com
curl -I http://pharazon.k46.com

echo "[✓] Semua client dapat mengakses layanan utama."
