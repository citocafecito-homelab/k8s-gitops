#!/bin/bash
JSON_FILE="/config/settings.json"
STATUS_FILE="/config/pia_port.txt"

# 1. Si los archivos no existen, aún está arrancando. El probe pasa limpio.
if [ ! -s "$STATUS_FILE" ] || [ ! -f "$JSON_FILE" ]; then
    exit 0
fi

# Leer puertos (Limpiando espacios y saltos de línea molestos)
PIA_PORT=$(cat "$STATUS_FILE" | tr -d '[:space:]')
CURRENT_TRANS_PORT=$(grep '"peer-port"' "$JSON_FILE" | sed -E 's/.*: ([0-9]+),?/\1/' | tr -d '[:space:]')

# Validar si existe desincronización
if [ "$PIA_PORT" != "$CURRENT_TRANS_PORT" ]; then
    echo "[DESINCRONIZADO] Puerto PIA ($PIA_PORT) != Transmission ($CURRENT_TRANS_PORT). Actualizando en caliente..."

    # Leer credenciales usando las variables de entorno inyectadas en tu manifiesto
    USER=$(cat "$FILE__USER" | tr -d '[:space:]')
    PASS=$(cat "$FILE__PASS" | tr -d '[:space:]')

    # Extraer el puerto RPC dinámicamente del JSON
    RPC_PORT=$(grep '"rpc-port"' "$JSON_FILE" | sed -E 's/.*: ([0-9]+),?/\1/' | tr -d '[:space:]')

    # Pausar inmediatamente todos los torrentes por seguridad
    # transmission-remote "localhost:${RPC_PORT}" -n "${USER}:${PASS}" -t all -S >/dev/null 2>&1

    # Intentar actualizar Transmission en memoria vía RPC
    transmission-remote "localhost:${RPC_PORT}" -n "${USER}:${PASS}" -p "$PIA_PORT" >/dev/null 2>&1
    RPC_STATUS=$?

    if [ $RPC_STATUS -eq 0 ]; then
        echo "[OK] Puerto actualizado exitosamente en Transmission RPC a: $PIA_PORT"
        
        # Persistir el cambio en el settings.json de forma segura
        sed -i "s/\"peer-port\": $CURRENT_TRANS_PORT/\"peer-port\": $PIA_PORT/g" "$JSON_FILE"
        echo "[OK] settings.json actualizado de forma persistente."
        
        exit 0 # El puerto se arregló en caliente, el Probe es EXITOSO (no hay reinicio)
    else
        echo "[ERROR] No se pudo conectar con Transmission RPC en localhost:${RPC_PORT}. Forzando reinicio del contenedor..."
        exit 1 # ERROR: El RPC falló (Transmission colgado o malas credenciales), K8s reinicia el contenedor
    fi
fi

# Si los puertos ya eran iguales desde el principio
exit 0