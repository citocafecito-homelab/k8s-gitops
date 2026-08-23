#!/bin/bash
# /scripts/common.sh

send_ntfy() {
    local title="$1"
    local message="$2"
    local tags="${3:-transmission}"
    local priority="${4:-default}"

    # Cargar token desde Vault si el secreto existe
    local auth_header=()
    if [ -f "/vault/secrets/ntfy" ]; then
        local token
        token=$(cat /vault/secrets/ntfy | tr -d '[:space:]')
        if [ -n "$token" ]; then
            auth_header=(-H "Authorization: Bearer ${token}")
        else
            echo "[NTFY-WARN] El archivo /vault/secrets/ntfy existe pero está vacío." >&2
        fi
    else
        echo "[NTFY-WARN] No se encontró /vault/secrets/ntfy. Enviando sin token de autenticación." >&2
    fi

    # Capturar la respuesta HTTP y guardar posibles errores de red/curl en un temporal
    local curl_err_file
    curl_err_file=$(mktemp)
    
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        "${auth_header[@]}" \
        -H "Title: ${title}" \
        -H "Icon: https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/transmission.png" \
        -H "Tags: ${tags}" \
        -H "Priority: ${priority}" \
        -d "${message}" \
        http://ntfy.core.svc.cluster.local/transmission 2>"$curl_err_file")

    local exit_code=$?

    # Manejo de excepciones (Catch)
    if [ $exit_code -ne 0 ]; then
        echo "[NTFY-ERROR] Falló la ejecución de curl (Exit code: $exit_code)." >&2
        echo "[NTFY-ERROR] Detalle: $(cat "$curl_err_file")" >&2
        rm -f "$curl_err_file"
        return 1
    fi

    rm -f "$curl_err_file"

    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "[NTFY-SUCCESS] Notificación enviada correctamente (HTTP $http_code)."
        return 0
    else
        echo "[NTFY-ERROR] ntfy respondió con código de error HTTP: $http_code." >&2
        
        # Puntos habituales de falla para depuración
        case "$http_code" in
            401|403) echo "[NTFY-ERROR] Error de autenticación. Revisa el token en /vault/secrets/ntfy." >&2 ;;
            404)     echo "[NTFY-ERROR] El tema/topic 'transmission' o la URL no existe." >&2 ;;
            500|502|503) echo "[NTFY-ERROR] El servidor ntfy tiene problemas internos o no está alcanzable." >&2 ;;
        esac
        return 1
    fi
}