#!/bin/bash
source /scripts/ntfy.sh

TORRENT_NAME="$1"
TORRENT_CATEGORY="$2"
TORRENT_PATH="$3"

BODY="Torrent: ${TORRENT_NAME:-Desconocido}
Categoría: ${TORRENT_CATEGORY:-Ninguna}
Ruta: ${TORRENT_PATH:-Desconocida}"

# Desvinculación total para que qBittorrent no espere absolutamente nada
(
    send_ntfy "qBittorrent: Torrent Añadido" \
              "$BODY" \
              "inbox,arrow_down" \
              "low" \
              "qbittorrent"
) </dev/null >/dev/null 2>&1 &

disown