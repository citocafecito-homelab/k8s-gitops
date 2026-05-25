#!/bin/bash
JSON_FILE="/config/settings.json"
PIA_STATUS="/config/pia_port.txt"

echo "[CUSTOM-INIT] Configurando Transmission..."

# Esperar a que Gluetun cree el archivo del puerto (máximo 1 min)
for i in {1..6}; do
    [ -f "$PIA_STATUS" ] && break
    echo "[CUSTOM-INIT] Esperando puerto de PIA..."
    sleep 10
done

if [ -f "$JSON_FILE" ]; then
    # --- Configuración de Automatización ---
    sed -i 's/"script-torrent-added-enabled":.*/"script-torrent-added-enabled": true,/g' "$JSON_FILE"
    sed -i 's|"script-torrent-added-filename":.*|"script-torrent-added-filename": "/scripts/added.sh",|g' "$JSON_FILE"
    
    # --- Configuración de Incompletos y Ratio ---
    sed -i 's/"incomplete-dir-enabled":.*/"incomplete-dir-enabled": false,/g' "$JSON_FILE"
    sed -i 's/"rename-partial-files":.*/"rename-partial-files": false,/g' "$JSON_FILE"
    sed -i 's/"ratio-limit":.*/"ratio-limit": 3.0,/g' "$JSON_FILE"
    sed -i 's/"ratio-limit-enabled":.*/"ratio-limit-enabled": true,/g' "$JSON_FILE"

    # --- Configuración para trackers privados
    sed -i 's/"encryption": .*/"encryption": 2,/g' "$JSON_FILE"
    sed -i 's/"cache-size-mb": .*/"cache-size-mb": 256,/g' "$JSON_FILE"
    sed -i 's/"peer-limit-global": .*/"peer-limit-global": 500,/g' "$JSON_FILE"
    sed -i 's/"upload-slots-per-torrent": .*/"upload-slots-per-torrent": 8,/g' "$JSON_FILE"
    

    # --- Inyección de Puerto Dinámico ---
    if [ -f "$PIA_STATUS" ]; then
        PIA_PORT=$(cat "$PIA_STATUS")
        if [[ "$PIA_PORT" =~ ^[0-9]+$ ]]; then
            echo "[INIT] Aplicando puerto de PIA: $PIA_PORT"
            # Si "peer-port" ya existe, lo actualiza. Si no, lo agrega después de la primera llave.
            if grep -q '"peer-port"' "$JSON_FILE"; then
                sed -i "s/\"peer-port\": [0-9]*/\"peer-port\": $PIA_PORT/" "$JSON_FILE"
            else
                sed -i "s/{/{\n    \"peer-port\": $PIA_PORT,/" "$JSON_FILE"
            fi
        fi
    fi
    echo "[CUSTOM-INIT] Configuración aplicada exitosamente."
else
    echo "[CUSTOM-INIT] settings.json no encontrado. Se creará con valores por defecto al arrancar."
fi