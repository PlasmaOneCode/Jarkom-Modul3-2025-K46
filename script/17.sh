#!/bin/bash
# Jalankan dari Client
set -euo pipefail

# Install apache2-utils
if ! command -v ab &> /dev/null; then
    echo "[*] Installing apache2-utils..."
    apt-get update -y
    apt-get install -y apache2-utils
fi

TARGET="http://pharazon.k46.com/"

echo ""
echo "BENCHMARK NORMAL (dengan auth)"
ab -n 1000 -c 50 -A noldor:silvan $TARGET

echo ""
echo "Amati distribusi beban:"
echo "  tail -50 /var/log/nginx/pharazon_access.log"
echo ""
echo "TEST FAILOVER"
echo ""
echo "Simulasikan Galadriel runtuh..."
echo "Di node Galadriel, jalankan: service nginx stop"
echo ""
echo "Tekan Enter setelah mematikan Galadriel..."
read

echo ""
echo "Menjalankan benchmark lagi..."
ab -n 500 -c 25 -A noldor:silvan $TARGET

echo ""
echo "Periksa log Pharazon:"
echo "tail -50 /var/log/nginx/pharazon_access.log"
echo "grep 'upstream' /var/log/nginx/pharazon_error.log"
echo ""
echo "Hidupkan kembali Galadriel:"
echo "service nginx start (di Galadriel)"
echo ""