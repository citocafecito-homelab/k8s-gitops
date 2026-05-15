#!/bin/bash
JSON_FILE="/config/settings.json"
STATUS_FILE="/config/pia_port.txt"

# 1. Si los archivos no existen, aún está arrancando.
if [ ! -f "$STATUS_FILE" ] || [ ! -f "$JSON_FILE" ]; then
    exit 0
fi

# 2. Leer puertos
PIA_PORT=$(cat "$STATUS_FILE")
# Extraer el valor numérico de peer-port del settings.json
CURRENT_TRANS_PORT=$(grep '"peer-port"' "$JSON_FILE" | sed -E 's/.*: ([0-9]+),?/\1/' | tr -d ' ')

# 3. Validar consistencia
if [ -z "$PIA_PORT" ] || [ -z "$CURRENT_TRANS_PORT" ]; then
    exit 0 # Evitar reinicios infinitos si el archivo está vacío momentáneamente
fi

if [ "$PIA_PORT" != "$CURRENT_TRANS_PORT" ]; then
    echo "[DESINCRONIZADO] Puerto PIA ($PIA_PORT) != Transmission ($CURRENT_TRANS_PORT). Forzando reinicio..."
    exit 1 # Kubernetes matará el contenedor
fi

exit 0