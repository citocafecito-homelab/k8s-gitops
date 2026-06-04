#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
JSON_FILE="/config/settings.json"

echo "[CUSTOM-INIT] Configurando Transmission..."

touch /config/queue.json

if [ -f "$JSON_FILE" ]; then
    # -- Configuración base
    sed -i 's|"download-dir":.*|"download-dir": "/downloads",|g' "$JSON_FILE"
    
    # --- Configuración de Automatización ---
    sed -i 's/"script-torrent-added-enabled":.*/"script-torrent-added-enabled": true,/g' "$JSON_FILE"
    sed -i 's|"script-torrent-added-filename":.*|"script-torrent-added-filename": "/scripts/added.sh",|g' "$JSON_FILE"

    sed -i 's/"script-torrent-done-enabled":.*/"script-torrent-done-enabled": true,/g' "$JSON_FILE"
    sed -i 's|"script-torrent-done-filename":.*|"script-torrent-done-filename": "/scripts/finished.sh",|g' "$JSON_FILE"

    # --- Configuración de Incompletos y Ratio ---
    sed -i 's/"incomplete-dir-enabled":.*/"incomplete-dir-enabled": false,/g' "$JSON_FILE"
    sed -i 's/"rename-partial-files":.*/"rename-partial-files": false,/g' "$JSON_FILE"
    sed -i 's/"ratio-limit":.*/"ratio-limit": 3.0,/g' "$JSON_FILE"
    sed -i 's/"ratio-limit-enabled":.*/"ratio-limit-enabled": true,/g' "$JSON_FILE"

    # 2. Sin colas, todo a full (Remueve cuellos de botella)
    sed -i 's/"download-queue-enabled":.*/"download-queue-enabled": false,/g' "$JSON_FILE"
    sed -i 's/"seed-queue-enabled":.*/"seed-queue-enabled": false,/g' "$JSON_FILE"
    sed -i 's/"download-queue-size":.*/"download-queue-size": 999,/g' "$JSON_FILE"
    sed -i 's/"seed-queue-size":.*/"seed-queue-size": 999,/g' "$JSON_FILE"

    # Networking
    sed -i 's/"peer-port-random-on-start":.*/"peer-port-random-on-start": true,/g' "$JSON_FILE"
    sed -i 's/"peer-limit-per-torrent":.*/"peer-limit-per-torrent": 20,/g' "$JSON_FILE"

    echo "[CUSTOM-INIT] Configuración aplicada exitosamente."
else
    echo "[CUSTOM-INIT] settings.json no encontrado. Se creará con valores por defecto al arrancar."
fi

# if [ -f "$JSON_FILE" ]; then
#     # Modificar el JSON de forma segura usando jq
#     TMP_FILE=$(mktemp)
#     jq '
#       ."download-dir" = "/downloads" |
#       ."script-torrent-added-enabled" = true |
#       ."script-torrent-added-filename" = "/scripts/added.sh" |
#       ."script-torrent-done-enabled" = true |
#       ."script-torrent-done-filename" = "/scripts/torrent_finished.sh" |
#       ."incomplete-dir-enabled" = false |
#       ."rename-partial-files" = false |
#       ."ratio-limit" = 3.0 |
#       ."ratio-limit-enabled" = true |
#       ."download-queue-enabled" = false |
#       ."seed-queue-enabled" = false |
#       ."download-queue-size" = 999 |
#       ."seed-queue-size" = 999 |
#       ."peer-port-random-on-start" = true |
#       ."peer-limit-per-torrent" = 20
#     ' "$JSON_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$JSON_FILE"

#     echo "[CUSTOM-INIT] Configuración aplicada exitosamente con jq."
# else
#     echo "[CUSTOM-INIT] settings.json no encontrado. Se creará con valores por defecto al arrancar."
# fi