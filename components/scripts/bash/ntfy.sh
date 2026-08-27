#!/bin/sh
# /scripts/common.sh

send_ntfy() {
    local title="$1"
    local message="$2"
    local tags="${3:-default}"
    local priority="${4:-default}"
    local topic="${5:-default}"

    local wget_err_file
    wget_err_file=$(mktemp)

    # Extraer el token/valor de auth_header si existe la variable
    local auth_header_cmd=""
    if [ -n "$auth_header" ]; then
        auth_header_cmd="--header=$auth_header"
    fi

    # Ejecutar wget (compatible con BusyBox wget)
    wget -nv -O /dev/null \
        --server-response \
        $auth_header_cmd \
        --header="Title: ${title}" \
        --header="Icon: https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/${topic}.png" \
        --header="Tags: ${tags}" \
        --header="Priority: ${priority}" \
        --post-data="${message}" \
        "http://ntfy-internal.core.svc.cluster.local/${topic}" \
        2>"$wget_err_file"

    local exit_code=$?

    # Extraer código HTTP en POSIX (evita flags avanzadas de grep/awk)
    local http_code
    http_code=$(grep 'HTTP/' "$wget_err_file" | tail -n 1 | sed -n 's/.*HTTP\/[0-9.]* \([0-9]*\).*/\1/p')

    if [ -z "$http_code" ] && [ $exit_code -ne 0 ]; then
        echo "[NTFY-ERROR] Falló la ejecución de wget (Exit code: $exit_code)." >&2
        echo "[NTFY-ERROR] Detalle: $(cat "$wget_err_file")" >&2
        rm -f "$wget_err_file"
        return 1
    fi

    rm -f "$wget_err_file"

    if [ -n "$http_code" ] && [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "[NTFY-SUCCESS] Notificación enviada correctamente (HTTP $http_code)."
        return 0
    else
        echo "[NTFY-ERROR] ntfy respondió con código de error HTTP: ${http_code:-desconocido}." >&2
        
        case "$http_code" in
            401|403) echo "[NTFY-ERROR] Error devuelto por el proxy interno." >&2 ;;
            404)     echo "[NTFY-ERROR] El tema/topic ${topic} o la existe." >&2 ;;
            500|502|503) echo "[NTFY-ERROR] El servidor ntfy o su proxy tiene problemas internos." >&2 ;;
        esac
        return 1
    fi
}