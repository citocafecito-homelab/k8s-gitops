#!/bin/bash

STATUS_FILE="/config/pia_port.txt"

# 1. Validar que el archivo del puerto de PIA exista (Montado desde el host/NFS)
if [ ! -f "$STATUS_FILE" ]; then
    echo "[CRON-ERROR] Archivo de puerto PIA no encontrado en $STATUS_FILE"
    exit 1
fi

USER=$(cat "$FILE__USER" | tr -d '[:space:]')
PASS=$(cat "$FILE__PASS" | tr -d '[:space:]')

RPC_URL="transmission.streaming.svc.cluster.local"

PIA_PORT=$(cat "$STATUS_FILE" | tr -d '[:space:]')

if [ -z "$PIA_PORT" ]; then
    echo "[CRON-ERROR] No se pudo leer el puerto desde $STATUS_FILE."
    exit 1
fi

export TR_AUTH="${USER}:${PASS}"

echo "[CRON] Consultando puerto actual en la API de Transmission..."
CURRENT_TRANS_PORT=$(transmission-remote "$RPC_URL" --authenv -si | grep "Listen port:" | awk '{print $3}')

if [ -z "$CURRENT_TRANS_PORT" ]; then
    echo "[CRON-ERROR] No se pudo conectar con el RPC de Transmission en $RPC_URL"
    exit 1
fi

# 4. Validar y actualizar si están desincronizados
if [ "$PIA_PORT" != "$CURRENT_TRANS_PORT" ]; then
    echo "[DESINCRONIZADO] Puerto PIA ($PIA_PORT) != Transmission ($CURRENT_TRANS_PORT). Actualizando en caliente..."

    # Opcional: Pausar torrents si lo descomentas
    transmission-remote "$RPC_URL" --authenv -t all -S >/dev/null 2>&1

    sleep 120

    # Actualizar Transmission en memoria vía RPC
    transmission-remote "$RPC_URL" --authenv -p "$PIA_PORT" >/dev/null 2>&1
    RPC_STATUS=$?

    if [ $RPC_STATUS -eq 0 ]; then
        echo "[OK] Puerto actualizado exitosamente en Transmission RPC a: $PIA_PORT"
        
        transmission-remote "$RPC_URL" --authenv -t all -s >/dev/null 2>&1
        exit 0
    else
        echo "[ERROR] Falló la actualización del puerto a través del comando RPC."
        exit 1
    fi
else
    echo "[OK] Los puertos ya están sincronizados ($PIA_PORT). Nada que hacer."
    exit 0
fi