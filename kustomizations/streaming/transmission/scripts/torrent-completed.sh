#!/bin/bash

# See more https://github.com/transmission/transmission/blob/main/docs/Scripts.md#on-torrent-completion
source /scripts/ntfy.sh

echo "$(date): Procesando torrent $TR_TORRENT_NAME (ID: $TR_TORRENT_ID)"

RPC_AUTH="$(cat /vault/secrets/user):$(cat /vault/secrets/password)"

if [[ ! "$TR_TORRENT_LABELS" =~ "private" ]]; then
    echo "$(date): El torrent es PÚBLICO (no tiene tag 'private'). Eliminando..."
    
    transmission-remote localhost:9091 --auth="$RPC_AUTH" -t "$TR_TORRENT_ID" --remove-and-delete

    TARGET_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"
    if [ -e "$TARGET_PATH" ]; then
        rm -rf "$TARGET_PATH"
        echo "$(date): Eliminado manualmente: $TARGET_PATH"
    fi

    send_ntfy "Transmission - Torrent Eliminado" \
              "El torrent público '$TR_TORRENT_NAME' cumplió ratio y fue eliminado." \
              "wastebasket,public" \
              "low" \
              "transmission"
else
    echo "$(date): El torrent es PRIVADO. Se mantiene en seed."
    send_ntfy "Transmission - Seeding Finalizado" \
              "El torrent privado '$TR_TORRENT_NAME' ha alcanzado la meta de ratio." \
              "seedling,lock" \
              "low" \
              "transmission"
fi