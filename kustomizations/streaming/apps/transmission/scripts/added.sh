#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Scripts.md

source /scripts/common.sh

if [ -n "$TR_TORRENT_HASH" ]; then
    /bin/echo "$TR_TORRENT_HASH" >> /config/pending_tags.txt
    /bin/echo "[TRIGGER] Hash $TR_TORRENT_HASH enviado a la cola."

    # Ruta del torrent
    LOCATION="${TR_TORRENT_DIR:-Desconocida}"

    # Consulta si el torrent está pausado o iniciado mediante transmisión-remote
    # Si usas credenciales en Transmission, añade: -n 'usuario:password'
    STATUS_RAW=$(transmission-remote -t "$TR_TORRENT_HASH" -i 2>/dev/null | grep "State:" | awk '{print $2}')

    case "$STATUS_RAW" in
        "Stopped"|"Finished") STATUS="Pausado" ;;
        "Downloading"|"Seeding"|"Queued"*) STATUS="Iniciado" ;;
        *) STATUS="Desconocido" ;;
    esac

    BODY="Torrent: ${TR_TORRENT_NAME:-$TR_TORRENT_HASH}
Estado: $STATUS
Ruta: $LOCATION"
else
    /bin/echo "[TRIGGER] Error: Variable TR_TORRENT_HASH no detectada."
    BODY="Error: Variable TR_TORRENT_HASH no detectada"
fi

send_ntfy "Transmission - Init" \
          "$BODY" \
          "seedling,lock" \
          "low"