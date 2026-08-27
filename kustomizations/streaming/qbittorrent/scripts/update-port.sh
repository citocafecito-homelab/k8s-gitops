#!/bin/sh
# /scripts/update-port.sh
# shellcheck source=/scripts/ntfy.sh
. /scripts/ntfy.sh

PORT="$1"
QBITTORRENT_URL="${QBITTORRENT_URL:-http://127.0.0.1:8080}"

if [ -z "$PORT" ]; then
    echo "[ERROR] No se recibió el puerto desde Gluetun."
    send_ntfy "qBittorrent: Error de Puerto" "El hook de Gluetun se ejecutó sin puerto." "warning,x" "high" "qbittorrent"
    exit 1
fi

AUTH_HEADER=""
if [ -n "$API_KEY" ]; then
    AUTH_HEADER="Authorization: Bearer $API_KEY"
fi

# 1. Esperar a que la WebUI responda (15 reintentos x 4s = 60s max)
MAX_RETRIES=15
RETRY=0
READY=0

until [ $READY -eq 1 ] || [ $RETRY -eq $MAX_RETRIES ]; do
    RETRY=$((RETRY+1))
    echo "[WAIT] Esperando respuesta de qBittorrent WebUI ($RETRY/$MAX_RETRIES)..."
    
    # Realiza un GET real en lugar de --spider (HEAD)
    if wget -O- -q --header="$AUTH_HEADER" "${QBITTORRENT_URL}/api/v2/app/version" >/dev/null 2>&1 || \
       wget -O- -q "${QBITTORRENT_URL}/" >/dev/null 2>&1; then
        READY=1
    else
        sleep 4
    fi
done

if [ $READY -eq 0 ]; then
    echo "[ERROR] No se pudo conectar a la WebUI de qBittorrent."
    send_ntfy "qBittorrent: Error de Conexión" "La API WebUI en $QBITTORRENT_URL no respondió al asignar puerto $PORT." "warning,x" "high" "qbittorrent"
    exit 1
fi

# 2. Actualizar el puerto (setPreferences)
POST_DATA="json=%7B%22listen_port%22%3A%20${PORT}%7D"

if wget -O- -q --header="$AUTH_HEADER" --post-data="$POST_DATA" "${QBITTORRENT_URL}/api/v2/app/setPreferences" >/dev/null 2>&1; then
    echo "[SUCCESS] Puerto actualizado exitosamente a $PORT"
    send_ntfy "qBittorrent: Puerto Actualizado" "El puerto de escucha se actualizó a $PORT." "gear,arrow_right" "low" "qbittorrent"
    exit 0
else
    echo "[ERROR] Falló la actualización del puerto vía API."
    send_ntfy "qBittorrent: Error Actualización" "Falló la actualización del puerto a $PORT." "warning,x" "high" "qbittorrent"
    exit 1
fi