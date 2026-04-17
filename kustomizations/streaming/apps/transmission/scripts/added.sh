#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Scripts.md

if [ -n "$TR_TORRENT_HASH" ]; then
    /bin/echo "$TR_TORRENT_HASH" >> /config/pending_tags.txt
    /bin/echo "[TRIGGER] Hash $TR_TORRENT_HASH enviado a la cola."
else
    /bin/echo "[TRIGGER] Error: Variable TR_TORRENT_HASH no detectada."
fi