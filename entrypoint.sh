#!/bin/bash
set -e

SECRET="${SECRET:-e4369939998facee16f16180a9c7070a}"
USERNAME="${USERNAME:-test_proxy}"
PORT="${PORT:-443}"
TLS_DOMAIN="${TLS_DOMAIN:-yandex.ru}"
LOG_LEVEL="${LOG_LEVEL:-normal}"
AD_TAG="${AD_TAG:-}"
API_TOKEN="${API_TOKEN:-}"

TLS_DOMAIN_HEX=$(echo -n "$TLS_DOMAIN" | od -A n -t x1 | tr -d ' \n')
EE_SECRET="ee${SECRET}${TLS_DOMAIN_HEX}"

echo "========================================="
echo " Telemt MTProxy starting..."
echo " Port:       $PORT"
echo " TLS Domain: $TLS_DOMAIN"
echo " Username:   $USERNAME"
echo " Secret:     $SECRET"
echo " EE Secret:  $EE_SECRET"
echo "========================================="

AD_TAG_LINE=""
if [ -n "$AD_TAG" ]; then
    AD_TAG_LINE="ad_tag = \"$AD_TAG\""
fi

API_TOKEN_LINE=""
if [ -n "$API_TOKEN" ]; then
    API_TOKEN_LINE="token = \"$API_TOKEN\""
fi

cat > /config.toml <<TOML
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
enabled = true
listen = "0.0.0.0:9091"
whitelist = ["0.0.0.0/0"]
$API_TOKEN_LINE
minimal_runtime_enabled = true
minimal_runtime_cache_ttl_ms = 5000

[[server.listeners]]
ip = "0.0.0.0"

[censorship]
tls_domain = "$TLS_DOMAIN"
mask = true
tls_emulation = true
tls_front_dir = "/data/tlsfront"

[access.users]
$USERNAME = "$SECRET"
TOML

mkdir -p /data/tlsfront

echo "Config generated, starting telemt..."
exec telemt /config.toml
