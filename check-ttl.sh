#!/usr/bin/env bash
set -euo pipefail

USER="${CB_USER:-Administrator}"
PASS="${CB_PASS:-password}"
HOST="${CB_HOST:-127.0.0.1}"
BUCKET="${CB_BUCKET:-server_metrics}"
INTERVAL="${INTERVAL:-5}"

echo "⏱ Monitoring document count every ${INTERVAL}s (CTRL+C to stop)..."
while true; do
  RAW=$(docker exec couchbase cbq -u "$USER" -p "$PASS" -s "SELECT COUNT(*) AS total FROM \`$BUCKET\`;" 2>/dev/null || true)

  # Extraer bloque JSON completo por balance de llaves (maneja llaves internas)
  JSON=$(printf '%s\n' "$RAW" | awk '
    BEGIN{capture=0; bal=0}
    {
      for (i=1;i<=length($0);i++) {
        c=substr($0,i,1)
        if (c=="{") { if(!capture){capture=1} bal++ }
        if (c=="}") bal--
      }
      if (capture) print $0
      if (capture && bal==0) exit
    }')

  # parsear con jq (fallback a grep)
  if command -v jq >/dev/null 2>&1; then
    COUNT=$(printf '%s' "$JSON" | jq -r '.results[0].total // 0' 2>/dev/null || echo "0")
  else
    COUNT=$(printf '%s' "$JSON" | grep -o '"total"[[:space:]]*:[[:space:]]*[0-9]*' | head -n1 | grep -o '[0-9]*' || echo "0")
  fi

  printf '%s | Documents in bucket: %s\n' "$(date '+%H:%M:%S')" "${COUNT:-0}"
  sleep "$INTERVAL"
done
