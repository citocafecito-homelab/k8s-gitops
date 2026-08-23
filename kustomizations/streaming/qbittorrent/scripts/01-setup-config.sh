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
    echo "" >> "$CONF_FILE"
    echo "[Preferences]" >> "$CONF_FILE"
fi

# Función segura para actualizar/insertar claves INI que contienen '\'
set_ini_key() {
    local key="$1"
    local value="$2"
    
    # Uso de grep -F para buscar el texto literal de la clave
    if grep -F -q "${key}=" "$CONF_FILE"; then
        # Escapar la clave para usarla de forma segura dentro de la Regex de sed
        local safe_key
        safe_key=$(printf '%s\n' "$key" | sed 's/[[\.*^$()/]/\\&/g')
        sed -i "s|^${safe_key}=.*|${key}=${value}|" "$CONF_FILE"
    else
        # Insertar directamente debajo de [Preferences]
        sed -i "/^\[Preferences\]/a ${key}=${value}" "$CONF_FILE"
    fi
}

# 1. Configurar hooks de scripts
set_ini_key "AutoRun\\Enabled" "true"
set_ini_key "AutoRun\\program" "/scripts/torrent-added.sh \"%N\" \"%L\" \"%F\""

set_ini_key "AutoRunOnTorrentFinished\\Enabled" "true"
set_ini_key "AutoRunOnTorrentFinished\\program" "/scripts/torrent-completed.sh \"%N\" \"%L\" \"%F\""

# 2. Configurar puerto de PIA si el archivo existe
if [ -f "$PORT_FILE" ] && [ -s "$PORT_FILE" ]; then
    PORT=$(cat "$PORT_FILE" | tr -d '[:space:]')
    if [ -n "$PORT" ]; then
        echo "[CUSTOM-INIT] Puerto forwarding de PIA detectado: $PORT"
        set_ini_key "Connection\\PortRangeMin" "$PORT"
    fi
else
    echo "[CUSTOM-INIT] No se encontró $PORT_FILE. Se mantiene la configuración existente."
fi

echo "[CUSTOM-INIT] Configuración aplicada con éxito."

send_ntfy "qBittorrent: Configuración de Inicio" \
          "Script de entrada y estado de puerto procesados correctamente." \
          "gear,wrench" \
          "low"