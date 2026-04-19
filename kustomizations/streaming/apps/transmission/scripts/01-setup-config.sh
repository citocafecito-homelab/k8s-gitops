#!/bin/bash
JSON_FILE="/config/settings.json"
echo "[CUSTOM-INIT] Ajustando settings.json para automatización y rutas limpias..."

# Esperar a que el sistema de archivos esté listo
sleep 2

if [ -f "$JSON_FILE" ]; then
    # 1. Habilitar scripts de automatización (Added y Done)
    sed -i 's/"script-torrent-added-enabled": false/"script-torrent-added-enabled": true/g' "$JSON_FILE"
    sed -i 's|"script-torrent-added-filename": ""|"script-torrent-added-filename": "/scripts/added.sh"|g' "$JSON_FILE"
    sed -i 's/"script-torrent-done-enabled": false/"script-torrent-done-enabled": true/g' "$JSON_FILE"
    sed -i 's|"script-torrent-done-filename": ""|"script-torrent-done-filename": "/scripts/added.sh"|g' "$JSON_FILE"
    
    # 2. Desactivar el directorio 'incomplete'
    # Cambiamos el booleano a false
    sed -i 's/"incomplete-dir-enabled": true/"incomplete-dir-enabled": false/g' "$JSON_FILE"
    # Opcional: Limpiar la ruta para evitar ruido en logs
    sed -i 's|"incomplete-dir": "/downloads/incomplete"|"incomplete-dir": ""|g' "$JSON_FILE"
    
    # 3. Desactivar el renombrado de archivos .part (recomendado para consistencia)
    sed -i 's/"rename-partial-files": true/"rename-partial-files": false/g' "$JSON_FILE"

    # Habilitar script al terminar descarga y apuntar a finished.sh
    sed -i 's/"script-torrent-done-enabled": false/"script-torrent-done-enabled": true/g' "$JSON_FILE"
    sed -i 's|"script-torrent-done-filename": ".*"|"script-torrent-done-filename": "/scripts/finished.sh"|g' "$JSON_FILE"

    echo "[CUSTOM-INIT] Configuración aplicada: Scripts ACTIVOS y Directorio Incompleto DESACTIVADO."
else
    echo "[CUSTOM-INIT] ERROR: No se encontró settings.json en /config."
fi