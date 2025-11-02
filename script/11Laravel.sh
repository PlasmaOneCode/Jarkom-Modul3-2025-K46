#!/bin/bash
# Jalankan dari Client
set -euo pipefail

if ! command -v ab &> /dev/null; then
    echo "[*] Installing apache2-utils..."
    apt-get update -y
    apt-get install -y apache2-utils
fi

TARGET="http://elros.k46.com/api/airing"

echo ""
echo "SERANGAN AWAL: -n 100 -c 10"
ab -n 100 -c 10 $TARGET

echo ""
echo "Enter untuk melanjutkan ke serangan penuh..."
read

echo ""
echo "SERANGAN PENUH: -n 2000 -c 100"
ab -n 2000 -c 100 $TARGET

echo ""
echo "Periksa log di Elros:"
echo "  tail -100 /var/log/nginx/elros_access.log"
echo ""
echo "Cek distribusi beban:"
echo "  grep 'GET /api/airing' /var/log/nginx/elros_access.log | wc -l"
echo ""
echo "Monitor resource di workers:"
echo "  htop (di Elendil, Isildur, Anarion)"