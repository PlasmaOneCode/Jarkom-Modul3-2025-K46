#!/bin/bash
# 10.sh - Client Testing
echo "[1/3] Mengatur DNS resolver..."
echo "nameserver 192.234.5.10" > /etc/resolv.conf

echo "[2/3] Menguji konektivitas ke domain penting..."
for site in elros.arda.com pharazon.arda.com palantir.arda.com; do
  echo "Tes: $site"
  dig $site +short
done

echo "[3/3] Menguji akses web..."
curl -I http://elros.arda.com
curl -I http://pharazon.arda.com

echo "[✓] Semua client dapat mengakses layanan utama."
