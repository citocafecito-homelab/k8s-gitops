#!/bin/bash
echo "[DAEMON] Monitor de etiquetas iniciado..."

while true; do
  if [ -s /config/pending_tags.txt ]; then
    U=$(cat /vault/secrets/user)
    P=$(cat /vault/secrets/password)
    
    cp /config/pending_tags.txt /tmp/tagger_queue.txt
    
    for HASH in $(sort -u /tmp/tagger_queue.txt); do
      [ -z "$HASH" ] && continue
      
      INFO=$(transmission-remote localhost:9091 -n "$U:$P" -t "$HASH" -i 2>/dev/null)
      [ $? -ne 0 ] && continue

      # Validar metadatos mínimos
      if ! echo "$INFO" | grep -q "Name:"; then
        echo "[DEBUG] $HASH esperando metadatos..."
        continue
      fi

      # 1. Privacidad (Basado en tu salida real)
      IS_PUBLIC=$(echo "$INFO" | grep -i "Public torrent:" | awk '{print $3}')
      [ "$IS_PUBLIC" == "Yes" ] && PRIVACY="public" || PRIVACY="private"
      
      # 2. Origen (Source -> Announce URL -> Magnet URL)
      ORIGIN=$(echo "$INFO" | grep -i "Source:" | sed 's/.*Source: //' | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
      
      if [ -z "$ORIGIN" ] || [ "$ORIGIN" == "none" ]; then
        # Intento A: Announce URL
        TRACKER_URL=$(echo "$INFO" | grep -i "Announce URL" | head -1 | awk '{print $3}')
        
        # Intento B: Extraer del Magnet (común en public/radarr)
        if [ -z "$TRACKER_URL" ]; then
          TRACKER_URL=$(echo "$INFO" | grep -o 'tr=[^&]*' | head -1 | sed 's/tr=//')
        fi

        if [ ! -z "$TRACKER_URL" ]; then
          # Limpieza de URL (percent-encoding simple para dominios)
          ORIGIN=$(echo "$TRACKER_URL" | sed 's/%3A/:/g; s/%2F/\//g' | cut -d '/' -f 3 | cut -d ':' -f 1 | rev | cut -d '.' -f 1,2 | rev | cut -d '.' -f 1)
        fi
      fi

      # 3. Construir etiquetas
      NEW_TAGS="$PRIVACY"
      [ ! -z "$ORIGIN" ] && [ "$ORIGIN" != "none" ] && NEW_TAGS="${NEW_TAGS},${ORIGIN}"

      # Obtener etiquetas de Radarr/Sonarr
      CURRENT=$(echo "$INFO" | grep "Labels:" | sed 's/.*Labels: //' | xargs)
      
      if [ ! -z "$CURRENT" ] && [ "$CURRENT" != "None" ]; then
        FINAL_LABELS=$(echo "${CURRENT},${NEW_TAGS}" | tr ',' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')
      else
        FINAL_LABELS="$NEW_TAGS"
      fi

      # Aplicar y limpiar
      echo "[DAEMON] Actualizando $HASH -> $FINAL_LABELS"
      OUTPUT=$(transmission-remote localhost:9091 -n "$U:$P" -t "$HASH" -L "$FINAL_LABELS" 2>&1)
      EXIT_CODE=$?
      
      if [ $EXIT_CODE -eq 0 ] || [[ "$OUTPUT" == *"success"* ]]; then
          echo "[DEBUG] Éxito. Borrando $HASH de la cola."
          
          # Uso de redirección para mantener el ownership (1000:1000) en el nodo castillo
          grep -v "$HASH" /config/pending_tags.txt > /config/pending_tags.tmp
          cat /config/pending_tags.tmp > /config/pending_tags.txt
          rm /config/pending_tags.tmp
        else
          echo "[ERROR] Falló actualización de $HASH: $OUTPUT"
        fi
    done
  fi
  sleep 10
done