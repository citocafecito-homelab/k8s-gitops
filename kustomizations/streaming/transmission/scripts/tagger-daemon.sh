#!/bin/bash

source /scripts/common.sh

echo "[CRON-TAGGER] Iniciando ciclo de procesamiento de etiquetas..."

STATUS_FILE="/config/pending_tags.txt"
TMP_FILE="/tmp/tagger_queue.txt"

USER=$(cat "$FILE__USER" | tr -d '[:space:]')
PASS=$(cat "$FILE__PASS" | tr -d '[:space:]')

RPC_URL="transmission.streaming.svc.cluster.local"

export TR_AUTH="${USER}:${PASS}"

# Limpiar posibles saltos \r del archivo de estado antes de evaluar
if [ -f "$STATUS_FILE" ]; then
    sed -i 's/\r$//' "$STATUS_FILE"
fi

# Verificar si existe y NO está vacío (ignorando líneas en blanco)
if [ ! -f "$STATUS_FILE" ] || [ -z "$(grep -v '^[[:space:]]*$' "$STATUS_FILE")" ]; then
    echo "[CRON-TAGGER] No hay hashes pendientes. Finalizando de forma limpia."
    exit 0
fi

# Copiar y limpiar cola
grep -v '^[[:space:]]*$' "$STATUS_FILE" | sort -u > "$TMP_FILE"

while IFS= read -r HASH || [ -n "$HASH" ]; do
    # Limpiar cualquier residuo de retorno de carro
    HASH=$(echo "$HASH" | tr -d '\r\n')
    [ -z "$HASH" ] && continue
    
    echo "[CRON-TAGGER] Procesando hash: $HASH"
    INFO=$(transmission-remote "$RPC_URL" --authenv -t "$HASH" -i 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "[CRON-TAGGER-ERROR] No se pudo conectar a Transmission o el torrent no existe."
        continue
    fi

    if ! echo "$INFO" | grep -q "Name:"; then
        echo "[DEBUG] $HASH esperando metadatos..."
        continue
    fi

    TORRENT_NAME=$(echo "$INFO" | grep "Name:" | sed 's/.*Name: //' | xargs)

    # 1. Privacidad
    IS_PUBLIC=$(echo "$INFO" | grep -i "Public torrent:" | awk '{print $3}')
    [ "$IS_PUBLIC" == "Yes" ] && PRIVACY="public" || PRIVACY="private"
    
    # 2. Origen (Source -> Announce URL -> Magnet URL)
    ORIGIN=$(echo "$INFO" | grep -i "Source:" | sed 's/.*Source: //' | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    
    if [ -z "$ORIGIN" ] || [ "$ORIGIN" == "none" ]; then
        TRACKER_URL=$(echo "$INFO" | grep -i "Announce URL" | head -1 | awk '{print $3}')
        
        if [ -z "$TRACKER_URL" ]; then
            TRACKER_URL=$(echo "$INFO" | grep -o 'tr=[^&]*' | head -1 | sed 's/tr=//')
        fi

        if [ -n "$TRACKER_URL" ]; then
            CLEAN_URL=$(echo "$TRACKER_URL" | sed 's/%3A/:/g; s/%2F/\//g')
            
            if echo "$CLEAN_URL" | grep -E -q '//|\.'; then
                ORIGIN=$(echo "$CLEAN_URL" | awk -F/ '{print $3}' | cut -d':' -f1 | sed -E 's/^(torrent|www|tracker)\.//i' | rev | cut -d'.' -f2- | rev | cut -d'.' -f1)
            else
                ORIGIN=$(echo "$CLEAN_URL" | tr '[:upper:]' '[:lower:]')
            fi
        fi
    fi

    # 3. Construir etiquetas
    NEW_TAGS="$PRIVACY"
    [ -n "$ORIGIN" ] && [ "$ORIGIN" != "none" ] && NEW_TAGS="${NEW_TAGS},${ORIGIN}"

    CURRENT=$(echo "$INFO" | grep "Labels:" | sed 's/.*Labels: //' | xargs)
    
    if [ -n "$CURRENT" ] && [ "$CURRENT" != "None" ]; then
        FINAL_LABELS=$(echo "${CURRENT},${NEW_TAGS}" | tr ',' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')
    else
        FINAL_LABELS="$NEW_TAGS"
    fi

    # Aplicar etiquetas vía RPC
    echo "[CRON-TAGGER] Actualizando $HASH -> [$FINAL_LABELS]"
    OUTPUT=$(transmission-remote "$RPC_URL" --authenv -t "$HASH" -L "$FINAL_LABELS" 2>&1)
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ] || [[ "$OUTPUT" == *"success"* ]]; then
        echo "[DEBUG] Éxito. Removiendo $HASH de la cola de forma segura."
        sed -i "/$HASH/d" "$STATUS_FILE"

        send_ntfy "Transmission - Etiquetas Asignadas" \
                  "Torrent: ${TORRENT_NAME:-$HASH}\nEtiquetas: [$FINAL_LABELS]" \
                  "label,tag" \
                  "low"
    else
        echo "[ERROR] Falló actualización de $HASH: $OUTPUT"
    fi
done < "$TMP_FILE"

[ -f "$TMP_FILE" ] && rm -f "$TMP_FILE"
echo "[CRON-TAGGER] Ejecución finalizada correctamente."
exit 0