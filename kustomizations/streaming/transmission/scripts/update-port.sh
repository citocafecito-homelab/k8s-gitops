#!/bin/sh
# /scripts/update-port.sh
# shellcheck source=/scripts/ntfy.sh
. /scripts/ntfy.sh

PORT="$1"
RPC_URL="http://127.0.0.1:9091/transmission/rpc"

if [ -z "$PORT" ]; then
    echo "[ERROR] No se recibió el puerto {{PORT}} desde Gluetun."
    send_ntfy "Transmission: Error de Puerto" "El hook de Gluetun se ejecutó sin puerto." "warning,x" "high"
    exit 1
fi

USER_PATH="${FILE__USER:-/vault/secrets/user}"
PASS_PATH="${FILE__PASS:-/vault/secrets/password}"

AUTH_HEADER=""
if [ -f "$USER_PATH" ] && [ -f "$PASS_PATH" ]; then
    USER=$(cat "$USER_PATH" | tr -d '[:space:]')
    PASS=$(cat "$PASS_PATH" | tr -d '[:space:]')
    AUTH_B64=$(printf "%s:%s" "$USER" "$PASS" | base64 | tr -d '[:space:]')
    AUTH_HEADER="Authorization: Basic $AUTH_B64"
fi

# 1. Obtener Session ID de Transmission
MAX_RETRIES=10
RETRY=0
SESSION_ID=""

until [ -n "$SESSION_ID" ] || [ $RETRY -eq $MAX_RETRIES ]; do
    RETRY=$((RETRY+1))
    echo "[WAIT] Esperando respuesta RPC ($RETRY/$MAX_RETRIES)..."
    
    SESSION_ID=$(wget -S --spider --header="$AUTH_HEADER" "$RPC_URL" 2>&1 | grep -i "X-Transmission-Session-Id:" | awk '{print $2}' | tr -d '\r\n')
    
    if [ -z "$SESSION_ID" ]; then
        sleep 3
    fi
done

if [ -z "$SESSION_ID" ]; then
    echo "[ERROR] No se obtuvo Session ID desde Transmission."
    send_ntfy "Transmission: Error RPC" "La API en $RPC_URL no respondió al asignar puerto $PORT." "warning,x" "high" "transmission"
    exit 1
fi

# 2. Actualizar el puerto (session-set)
RESPONSE=$(wget -O- -q --header="$AUTH_HEADER" \
  --header="X-Transmission-Session-Id: $SESSION_ID" \
  --post-data="{\"method\": \"session-set\", \"arguments\": {\"peer-port\": $PORT}}" \
  "$RPC_URL")

if echo "$RESPONSE" | grep -q '"result":"success"'; then
    echo "[SUCCESS] Puerto actualizado exitosamente a $PORT"
    send_ntfy "Transmission: Puerto Actualizado" "El puerto de escucha se actualizó a $PORT." "gear,arrow_right" "low" "transmission"
    exit 0
else
    echo "[ERROR] Falló la actualización RPC: $RESPONSE"
    send_ntfy "Transmission: Error Actualización" "Falló la actualización del puerto a $PORT." "warning,x" "high" "transmission"
    exit 1
fi