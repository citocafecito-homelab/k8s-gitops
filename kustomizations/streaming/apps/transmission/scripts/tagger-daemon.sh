#!/bin/bash
echo "[CRON-TAGGER] Iniciando ciclo de procesamiento de etiquetas..."

STATUS_FILE="/config/pending_tags.txt"
TMP_FILE="/tmp/tagger_queue.txt"

USER=$(cat "$FILE__USER" | tr -d '[:space:]')
PASS=$(cat "$FILE__PASS" | tr -d '[:space:]')

RPC_URL="transmission.streaming.svc.cluster.local"

export TR_AUTH="${USER}:${PASS}"

echo 
if [ ! -s "$STATUS_FILE" ]; then
    echo "[CRON-TAGGER] No hay hashes pendientes. Finalizando de forma limpia."
    exit 0
fi

cp "$STATUS_FILE" "$TMP_FILE"

for HASH in $(sort -u "$TMP_FILE"); do
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

    # 1. Privacidad
    IS_PUBLIC=$(echo "$INFO" | grep -i "Public torrent:" | awk '{print $3}')
    [ "$IS_PUBLIC" == "Yes" ] && PRIVACY="public" || PRIVACY="private"
    
    # 2. Origen (Source -> Announce URL -> Magnet URL)
    ORIGIN=$(echo "$INFO" | grep -i "Source:" | sed 's/.*Source: //' | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    
    if [ -z "$ORIGIN" ] || [ "$ORIGIN" == "none" ]; then
        # Intento A: Announce URL
        TRACKER_URL=$(echo "$INFO" | grep -i "Announce URL" | head -1 | awk '{print $3}')
        
        # Intento B: Extraer del Magnet
        if [ -z "$TRACKER_URL" ]; then
            TRACKER_URL=$(echo "$INFO" | grep -o 'tr=[^&]*' | head -1 | sed 's/tr=//')
        fi

        if [ ! -z "$TRACKER_URL" ]; then
            # 1. Descodificar caracteres URL (%3A -> :, %2F -> /)
            CLEAN_URL=$(echo "$TRACKER_URL" | sed 's/%3A/:/g; s/%2F/\//g')
            
            # 2. Validar si tiene formato de URL (contiene // o un punto)
            if echo "$CLEAN_URL" | grep -E -q '//|\.'; then
                # Extrae el host, remueve subdominios comunes (www, torrent) y el TLD (.com, .org, etc.)
                ORIGIN=$(echo "$CLEAN_URL" | awk -F/ '{print $3}' | cut -d':' -f1 | sed -E 's/^(torrent|www|tracker)\.//i' | rev | cut -d'.' -f2- | rev | cut -d'.' -f1)
            else
                # Si no es una URL, se mantiene el string intacto (ej. lat-team)
                ORIGIN=$(echo "$CLEAN_URL" | tr '[:upper:]' '[:lower:]')
            fi
        fi
    fi

    # 3. Construir etiquetas
    NEW_TAGS="$PRIVACY"
    [ ! -z "$ORIGIN" ] && [ "$ORIGIN" != "none" ] && NEW_TAGS="${NEW_TAGS},${ORIGIN}"

    # Obtener etiquetas existentes (inyectadas por Radarr/Sonarr)
    CURRENT=$(echo "$INFO" | grep "Labels:" | sed 's/.*Labels: //' | xargs)
    
    if [ ! -z "$CURRENT" ] && [ "$CURRENT" != "None" ]; then
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
        
        # Reescribir la cola de forma segura para no romper permisos (1000:1000) en el storage
        # Excluimos el hash actual y actualizamos el archivo vivo
        sed -i "/$HASH/d" "$STATUS_FILE"
    else
        echo "[ERROR] Falló actualización de $HASH: $OUTPUT"
    fi
done

# Limpieza final del archivo temporal
[ -f "$TMP_FILE" ] && rm "$TMP_FILE"
echo "[CRON-TAGGER] Ejecución finalizada correctamente."
exit 0