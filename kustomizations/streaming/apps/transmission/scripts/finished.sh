#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Scripts.md#on-torrent-completion

source /scripts/common.sh

echo "$(date): torrent $TR_TORRENT_NAME (ID: $TR_TORRENT_ID) ha finalizado su descarga"

send_ntfy "Transmission - Descarga Completada" \
          "Se ha completado la descarga de: $TR_TORRENT_NAME" \
          "white_check_mark,floppy_disk" \
          "default"