#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
JSON_FILE="/config/settings.json"

echo "[CUSTOM-INIT] Configurando Transmission..."

if [ -f "$JSON_FILE" ]; then
    # --- Configuración de Automatización ---
    sed -i 's/"script-torrent-added-enabled":.*/"script-torrent-added-enabled": true,/g' "$JSON_FILE"
    sed -i 's|"script-torrent-added-filename":.*|"script-torrent-added-filename": "/scripts/added.sh",|g' "$JSON_FILE"
    
    # --- Configuración de Incompletos y Ratio ---
    sed -i 's/"incomplete-dir-enabled":.*/"incomplete-dir-enabled": false,/g' "$JSON_FILE"
    sed -i 's/"rename-partial-files":.*/"rename-partial-files": false,/g' "$JSON_FILE"
    sed -i 's/"ratio-limit":.*/"ratio-limit": 3.0,/g' "$JSON_FILE"
    sed -i 's/"ratio-limit-enabled":.*/"ratio-limit-enabled": true,/g' "$JSON_FILE"

    # --- Configuración para trackers privados y estabilidad de red ---
    sed -i 's/"encryption":.*/"encryption": 2,/g' "$JSON_FILE"
    sed -i 's/"cache-size-mb":.*/"cache-size-mb": 256,/g' "$JSON_FILE"
    sed -i 's/"peer-limit-global":.*/"peer-limit-global": 500,/g' "$JSON_FILE"
    sed -i 's/"peer-limit-per-torrent":.*/"peer-limit-per-torrent": 50,/g' "$JSON_FILE"
    sed -i 's/"upload-slots-per-torrent":.*/"upload-slots-per-torrent": 8,/g' "$JSON_FILE"
    sed -i 's/"scrape-paused-torrents-enabled":.*/"scrape-paused-torrents-enabled": false,/g' "$JSON_FILE"

    # --- Parches Anti-Ban (Soporte para v3, v4 y v5) ---
    sed -i 's/"scrape-paused-torrents-enabled":.*/"scrape-paused-torrents-enabled": false,/g' "$JSON_FILE"
    sed -i 's/"scrape_paused_torrents_enabled":.*/"scrape_paused_torrents_enabled": false,/g' "$JSON_FILE"
    sed -i 's/"scrape_paused_torrents":.*/"scrape_paused_torrents": false,/g' "$JSON_FILE"
    sed -i 's/"announcement_timeout":.*/"announcement_timeout": 30,/g' "$JSON_FILE"
    
    echo "[CUSTOM-INIT] Configuración aplicada exitosamente."
else
    echo "[CUSTOM-INIT] settings.json no encontrado. Se creará con valores por defecto al arrancar."
fi