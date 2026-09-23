#!/bin/sh
set -e

CERT_DIR=/var/lib/pasarguard/certs
CERT=$CERT_DIR/ssl_cert.pem
KEY=$CERT_DIR/ssl_key.pem

mkdir -p "$CERT_DIR"

if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
  echo ">> در حال ساخت گواهی SSL برای PasarGuard..."
  openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
    -keyout "$KEY" \
    -out "$CERT" \
    -subj "/CN=panel" \
    2>/dev/null
fi

echo ">> در حال آپدیت جدول‌های دیتابیس..."
python -m alembic upgrade head

echo ">> در حال ساخت کد ورود موقت مالک..."
python pasarguard-cli.py generate-temp-key || true

echo ">> استارت Nginx روی پورت 8000..."
nginx

echo ">> استارت PasarGuard روی پورت 8001..."
exec python main.py
