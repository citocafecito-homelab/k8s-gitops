#!/bin/bash
source /scripts/ntfy.sh

TORRENT_NAME="$1"
TORRENT_CATEGORY="$2"
SAVE_PATH="$3"
TORRENT_SIZE="$4"

# Convertir bytes a un formato legible (MB/GB)
HUMAN_SIZE=$(numfmt --to=iec-i --suffix=B "${TORRENT_SIZE:-0}" 2>/dev/null || echo "${TORRENT_SIZE} B")

BODY="Torrent: ${TORRENT_NAME:-Desconocido}
Categoría: ${TORRENT_CATEGORY:-Ninguna}
Tamaño: ${HUMAN_SIZE}
Ruta: ${SAVE_PATH:-Desconocida}"

(
  send_ntfy "qBittorrent: Descarga Completada" \
            "$BODY" \
            "check,package" \
            "default" \
            "qbittorrent"
) &

exit 0