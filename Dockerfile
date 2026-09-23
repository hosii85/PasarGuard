FROM pasarguard/panel:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl nginx \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN rm -f /etc/nginx/sites-enabled/default \
    && printf '%s\n' \
'server {' \
'    listen 8000;' \
'    listen [::]:8000;' \
'    server_name _;' \
'' \
'    location / {' \
'        proxy_pass https://127.0.0.1:8001;' \
'        proxy_ssl_verify off;' \
'        proxy_http_version 1.1;' \
'        proxy_set_header Host $host;' \
'        proxy_set_header X-Real-IP $remote_addr;' \
'        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' \
'        proxy_set_header X-Forwarded-Proto https;' \
'        proxy_set_header Upgrade $http_upgrade;' \
'        proxy_set_header Connection "upgrade";' \
'    }' \
'}' \
> /etc/nginx/conf.d/pasarguard.conf

ENV UVICORN_HOST=127.0.0.1 \
    UVICORN_PORT=8001 \
    UVICORN_SSL_CERTFILE=/var/lib/pasarguard/certs/ssl_cert.pem \
    UVICORN_SSL_KEYFILE=/var/lib/pasarguard/certs/ssl_key.pem \
    UVICORN_SSL_CA_TYPE=private \
    ALLOWED_ORIGINS=* \
    ENABLE_RECORDING_NODES_STATS=True \
    PORT=8000

ENTRYPOINT ["/entrypoint.sh"]
