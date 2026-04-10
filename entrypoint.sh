#!/bin/bash
set -e

# Дефолтные значения
SECRET="${SECRET:-$(openssl rand -hex 16)}"
USERNAME="${USERNAME:-user}"
PORT="${PORT:-443}"
TLS_DOMAIN="${TLS_DOMAIN:-www.google.com}"
LOG_LEVEL="${LOG_LEVEL:-normal}"
AD_TAG="${AD_TAG:-}"

echo "========================================="
echo " Telemt MTProxy starting..."
echo " Port:       $PORT"
echo " TLS Domain: $TLS_DOMAIN"
echo " Username:   $USERNAME"
echo " Secret:     $SECRET"
echo ""
echo " Your proxy link:"
echo " tg://proxy?server=YOUR_HOST&port=$PORT&secret=ee$(echo -n $TLS_DOMAIN | xxd -p)$(echo $SECRET)"
echo "========================================="

# Генерируем hex из tls_domain для ссылки (ee-префикс = fake TLS режим)
TLS_DOMAIN_HEX=$(echo -n "$TLS_DOMAIN" | xxd -p | tr -d '\n')
echo ""
echo " Secret для Fake TLS (ee): ee${TLS_DOMAIN_HEX}${SECRET}"
echo "========================================="

# Опциональный ad_tag
AD_TAG_LINE=""
if [ -n "$AD_TAG" ]; then
    AD_TAG_LINE="ad_tag = \"$AD_TAG\""
fi

# Генерируем config.toml
cat > /config.toml <<EOF
[general]
use_middle_proxy = false
$AD_TAG_LINE
log_level = "$LOG_LEVEL"

[general.modes]
classic = false
secure = false
tls = true

[general.links]
show = "*"

[server]
port = $PORT

[server.api]
enabled = false
listen = "0.0.0.0:9091"
whitelist = ["0.0.0.0/0"]
minimal_runtime_enabled = false
minimal_runtime_cache_ttl_ms = 1000

[[server.listeners]]
ip = "0.0.0.0"

[censorship]
tls_domain = "$TLS_DOMAIN"
mask = true
tls_emulation = true
tls_front_dir = "/data/tlsfront"

[access.users]
$USERNAME = "$SECRET"
EOF

mkdir -p /data/tlsfront

echo "Config generated, starting telemt..."
exec telemt /config.toml
