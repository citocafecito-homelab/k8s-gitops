#!/bin/sh
echo "Iniciando comprobación de puerto PIA..."

PORT_FILE="/config/qBittorrent/gluetun/forwarded_port"
QBITTORRENT_URL="${QBITTORRENT_URL:-http://127.0.0.1:8080}"

if [ -f "$PORT_FILE" ]; then
    PORT=$(cat "$PORT_FILE")
    if [ -n "$PORT" ]; then
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$TIMESTAMP] Puerto detectado: $PORT. Actualizando qBittorrent..."

        RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
        -H "Authorization: Bearer ${API_KEY}" \
        -X POST "${QBITTORRENT_URL}/api/v2/app/setPreferences" \
        --data-urlencode "json={\"listen_port\": $PORT}")

        BODY=$(echo "$RESPONSE" | sed -e 's/HTTP_STATUS:.*//g')
        STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

        if [ "$STATUS" = "200" ]; then
            echo "[SUCCESS] Puerto actualizado a $PORT"
        else
            echo "[ERROR] Falló la actualización (HTTP $STATUS)"
            echo "[DEBUG] Respuesta: $BODY"
            exit 1
        fi
    fi
else
    echo "[WARN] Archivo $PORT_FILE no encontrado..."
fi