#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
JSON_FILE="/config/settings.json"

echo "[CUSTOM-INIT] Configurando Transmission..."

touch /config/pending_tags.txt
touch /config/queue.json

if [ -f "$JSON_FILE" ]; then
    # --- Configuración de Automatización ---
    sed -i 's/"script-torrent-added-enabled":.*/"script-torrent-added-enabled": true,/g' "$JSON_FILE"
    sed -i 's|"script-torrent-added-filename":.*|"script-torrent-added-filename": "/scripts/added.sh",|g' "$JSON_FILE"
    sed -i 's/"script-torrent-done-enabled":.*/"script-torrent-done-enabled": true,/g' "$JSON_FILE"
    sed -i 's|"script-torrent-done-filename":.*|"script-torrent-done-filename": "/scripts/torrent_finished.sh",|g' "$JSON_FILE"


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

    echo "[CUSTOM-INIT] Configuración aplicada exitosamente."
else
    echo "[CUSTOM-INIT] settings.json no encontrado. Se creará con valores por defecto al arrancar."
fi