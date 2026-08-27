#!/bin/bash
source /scripts/ntfy.sh

TORRENT_NAME="$1"
TORRENT_CATEGORY="$2"
TORRENT_PATH="$3"

BODY="Torrent: ${TORRENT_NAME:-Desconocido}
Categoría: ${TORRENT_CATEGORY:-Ninguna}
Ruta: ${TORRENT_PATH:-Desconocida}"

# Ejecución en segundo plano para evitar bloqueos
(
  send_ntfy "qBittorrent: Torrent Añadido" \
            "$BODY" \
            "inbox,arrow_down" \
            "low" \
            "qbittorrent"
) &

exit 0