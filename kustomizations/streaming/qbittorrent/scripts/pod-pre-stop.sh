#!/bin/sh
# shellcheck source=/scripts/common.sh
source /scripts/ntfy.sh

echo "[PRE-STOP] Deteniendo todos los torrents antes de apagar el Pod..."

QBITTORRENT_URL="${QBITTORRENT_URL:-http://127.0.0.1:8080}"

# Endpoint correcto para detener/pausar todos los torrents en qBittorrent API v2
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -H "Authorization: Bearer ${API_KEY}" \
  -X POST "${QBITTORRENT_URL}/api/v2/torrents/stop" \
  --data "hashes=all")

BODY=$(echo "$RESPONSE" | sed -e 's/HTTP_STATUS:.*//g')
STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

if [ "$STATUS" = "200" ]; then
    echo "[PRE-STOP-SUCCESS] Torrents pausados correctamente."
    send_ntfy "qBittorrent: Detenido" "Todos los torrents han sido pausados previo al apagado del Pod." "pause" "low" "qbittorrent"
    exit 0
else
    echo "[PRE-STOP-ERROR] Falló la pausa de torrents (HTTP $STATUS). Respuesta: $BODY"
    send_ntfy "qBittorrent: Error en PreStop" "No se pudieron pausar los torrents (HTTP $STATUS)." "warning" "high" "qbittorrent"
    # Salir con 0 para evitar que Kubernetes marque el hook como fallido si el contenedor ya se está cerrando
    exit 0
fi