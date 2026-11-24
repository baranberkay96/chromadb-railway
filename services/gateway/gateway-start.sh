#!/bin/sh
# Checks the gateway's variables, then runs Caddy. A bad value never stops the
# start (STANDARD 8.29): a missing or weak token locks the gateway with a random
# token nobody knows, and the log says how to fix it.
set -u

log() { printf 'chroma-gateway: %s\n' "$*"; }

TOKEN="${CHROMA_AUTH_TOKEN:-}"
if [ "${#TOKEN}" -lt 16 ] || ! printf '%s' "$TOKEN" | grep -Eq '^[A-Za-z0-9._~-]+$'; then
  log "WARNING: CHROMA_AUTH_TOKEN is missing, shorter than 16 characters or has characters other than A-Z a-z 0-9 . _ ~ -;"
  log "the gateway is LOCKED with a random token. Set CHROMA_AUTH_TOKEN on the Chroma Gateway service and redeploy."
  TOKEN=$(head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 40)
fi
export CHROMA_AUTH_TOKEN="$TOKEN"

UPSTREAM="${CHROMA_UPSTREAM:-}"
if ! printf '%s' "$UPSTREAM" | grep -Eq '^[A-Za-z0-9.-]+:[0-9]{1,5}$'; then
  log "WARNING: CHROMA_UPSTREAM='${UPSTREAM}' is not host:port; using chroma.railway.internal:8000"
  UPSTREAM=chroma.railway.internal:8000
fi
export CHROMA_UPSTREAM="$UPSTREAM"

case "${PORT:-}" in
  '' | *[!0-9]*) log "WARNING: PORT='${PORT:-}' is not a number; using 8080"; export PORT=8080 ;;
esac

log "forwarding authenticated requests on port ${PORT} to http://${CHROMA_UPSTREAM}"
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
