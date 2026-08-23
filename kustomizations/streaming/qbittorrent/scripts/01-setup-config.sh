#!/bin/bash

source /scripts/common.sh

echo "[CUSTOM-INIT] Configurando qBittorrent..."

CONF_DIR="/config/qBittorrent"
CONF_FILE="${CONF_DIR}/qBittorrent.conf"
PORT_FILE="/config/qBittorrent/gluetun/forwarded_port"

mkdir -p "$CONF_DIR"

# Asegurar que la sección [Preferences] exista
if [ ! -f "$CONF_FILE" ]; then
    cat <<EOF > "$CONF_FILE"
[Preferences]
EOF
elif ! grep -q "^\[Preferences\]" "$CONF_FILE"; then
    echo -e "\n[Preferences]" >> "$CONF_FILE"
fi

# Función para actualizar o insertar claves en [Preferences]
set_ini_key() {
    local key="$1"
    local value="$2"
    
    if grep -q "^${key}=" "$CONF_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$CONF_FILE"
    else
        sed -i "/^\[Preferences\]/a ${key}=${value}" "$CONF_FILE"
    fi
}

# 1. Configurar hook de script al añadir torrent
set_ini_key "AutoRun\\\\Enabled" "true"
set_ini_key "AutoRun\\\\program" "/scripts/torrent-added.sh \"%N\" \"%L\" \"%F\""

# 2. Configurar puerto de PIA únicamente si el archivo existe y no está vacío
if [ -f "$PORT_FILE" ] && [ -s "$PORT_FILE" ]; then
    PORT=$(cat "$PORT_FILE" | tr -d '[:space:]')
    if [ -n "$PORT" ]; then
        echo "[CUSTOM-INIT] Puerto forwarding de PIA detectado: $PORT"
        set_ini_key "Connection\\\\PortRangeMin" "$PORT"
    fi
else
    echo "[CUSTOM-INIT] No se encontró $PORT_FILE. Se mantiene la configuración de puerto existente."
fi

echo "[CUSTOM-INIT] Configuración aplicada con éxito."

send_ntfy "qBittorrent: Configuración de Inicio" \
          "Script de entrada y estado de puerto procesados correctamente." \
          "gear,wrench" \
          "low"