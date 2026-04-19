#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Scripts.md#on-torrent-completion

echo "$(date): Procesando torrent $TR_TORRENT_NAME (ID: $TR_TORRENT_ID)"

RPC_AUTH="$(cat /vault/secrets/user):$(cat /vault/secrets/password)"

if [[ ! "$TR_TORRENT_LABELS" =~ "private" ]]; then
    echo "$(date): El torrent es PÚBLICO (no tiene tag 'private'). Eliminando..."
    
    # Intentar eliminación por RPC primero
    transmission-remote localhost:9091 --auth="$RPC_AUTH" -t "$TR_TORRENT_ID" --remove-and-delete

    # Refuerzo manual por si quedan huérfanos
    TARGET_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"
    if [ -e "$TARGET_PATH" ]; then
        rm -rf "$TARGET_PATH"
        echo "$(date): Eliminado manualmente: $TARGET_PATH"
    else
        echo "$(date): El archivo ya no existía en $TARGET_PATH"
    fi
else
    echo "$(date): El torrent es PRIVADO. Se mantiene en seed."
fi