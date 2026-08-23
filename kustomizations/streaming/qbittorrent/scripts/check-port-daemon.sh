#!/bin/sh
# shellcheck source=/scripts/common.sh
. /scripts/common.sh

echo "Iniciando comprobación de puerto PIA..."

PORT_FILE="/config/qBittorrent/gluetun/forwarded_port"
QBITTORRENT_URL="${QBITTORRENT_URL:-http://127.0.0.1:8080}"

if [ -f "$PORT_FILE" ]; then
    PORT=$(cat "$PORT_FILE" | tr -d '[:space:]')
    if [ -n "$PORT" ]; then
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$TIMESTAMP] Puerto detectado: $PORT. Intentando conectar a la WebUI de qBittorrent..."

        # 1. Esperar a que el servicio WebUI responda (máximo 10 reintentos cada 3s)
        MAX_RETRIES=10
        RETRY=0
        until curl -s "${QBITTORRENT_URL}/api/v2/app/version" >/dev/null 2>&1 || [ $RETRY -eq $MAX_RETRIES ]; do
            RETRY=$((RETRY+1))
            echo "[WAIT] Esperando a que qBittorrent WebUI esté disponible ($RETRY/$MAX_RETRIES)..."
            sleep 3
        done

        if [ $RETRY -eq $MAX_RETRIES ]; then
            echo "[ERROR] La API WebUI de qBittorrent no respondió después de varios intentos."
            send_ntfy "qBittorrent: Error de Conexión" "No se pudo conectar a la WebUI en $QBITTORRENT_URL tras el arranque." "warning,x" "high"
            exit 1
        fi

        # 2. Enviar actualización de preferencias
        RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
            -H "Authorization: Bearer ${API_KEY}" \
            -X POST "${QBITTORRENT_URL}/api/v2/app/setPreferences" \
            --data-urlencode "json={\"listen_port\": $PORT}")

        BODY=$(echo "$RESPONSE" | sed -e 's/HTTP_STATUS:.*//g')
        STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

        if [ "$STATUS" = "200" ]; then
            echo "[SUCCESS] Puerto actualizado a $PORT"
            send_ntfy "qBittorrent: Puerto Actualizado" "El puerto de escucha se actualizó correctamente a $PORT." "gear,arrow_right" "low"
        else
            echo "[ERROR] Falló la actualización (HTTP $STATUS)"
            echo "[DEBUG] Respuesta: $BODY"
            send_ntfy "qBittorrent: Error de API" "No se pudo actualizar el puerto $PORT (HTTP $STATUS). Detalle: $BODY" "warning,x" "high"
            exit 1
        fi
    fi
else
    echo "[WARN] Archivo $PORT_FILE no encontrado..."
    send_ntfy "qBittorrent: Archivo No Encontrado" "El archivo $PORT_FILE no existe para sincronizar el puerto." "warning,file" "default"
fi