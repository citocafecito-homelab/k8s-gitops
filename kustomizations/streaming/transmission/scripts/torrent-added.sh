#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Scripts.md

source /scripts/ntfy.sh

if [ -n "$TR_TORRENT_HASH" ]; then
    /bin/echo "$TR_TORRENT_HASH" >> /config/pending_tags.txt
    /bin/echo "[TRIGGER] Hash $TR_TORRENT_HASH enviado a la cola."

    # Ruta del torrent
    LOCATION="${TR_TORRENT_DIR:-Desconocida}"

    # Consulta si el torrent está pausado o iniciado mediante transmission-remote
    STATUS_RAW=$(transmission-remote -t "$TR_TORRENT_HASH" -i 2>/dev/null | grep "State:" | awk '{print $2}')

    case "$STATUS_RAW" in
        "Stopped"|"Finished") STATUS="Pausado" ;;
        "Downloading"|"Seeding"|"Queued"*) STATUS="Iniciado" ;;
        *) STATUS="Desconocido" ;;
    esac

    BODY="Torrent: ${TR_TORRENT_NAME:-$TR_TORRENT_HASH}
Estado: $STATUS
Ruta: $LOCATION"

    send_ntfy "Transmission: Torrent Añadido" \
              "$BODY" \
              "inbox,arrow_down" \
              "low" \
              "transmission"
else
    /bin/echo "[TRIGGER] Error: Variable TR_TORRENT_HASH no detectada."
fi