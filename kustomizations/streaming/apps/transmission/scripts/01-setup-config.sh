#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
echo "[CUSTOM-INIT] Configurando Transmission..."

JSON_FILE="/config/settings.json"

if [ ! -f "$JSON_FILE" ]; then
    echo "{}" > "$JSON_FILE"
fi

modify_json() {
    local key=$1
    local value=$2
    if grep -q "$key" "$JSON_FILE"; then
        sed -i "s|$key.*|$key: $value,|g" "$JSON_FILE"
    else
        # Inserta la configuración justo después de la llave de apertura
        sed -i "s|{|{\n    $key: $value,|g" "$JSON_FILE"
    fi
}

modify_json '"download-dir"' '"/downloads"'
modify_json '"script-torrent-added-enabled"' 'true'
modify_json '"script-torrent-added-filename"' '"/scripts/added.sh"'
modify_json '"script-torrent-done-enabled"' 'false'
modify_json '"script-torrent-done-filename"' '"/scripts/finished.sh"'
modify_json '"script-torrent-done-seeding-enabled"' 'true'
modify_json '"script-torrent-done-seeding-filename"' '"/scripts/completed.sh"'
modify_json '"incomplete-dir-enabled"' 'false'
modify_json '"rename-partial-files"' 'false'
modify_json '"ratio-limit"' '3.0'
modify_json '"ratio-limit-enabled"' 'true'
modify_json '"download-queue-enabled"' 'false'
modify_json '"seed-queue-enabled"' 'false'
modify_json '"download-queue-size"' '999'
modify_json '"seed-queue-size"' '999'
modify_json '"peer-port-random-on-start"' 'true'
modify_json '"peer-limit-per-torrent"' '20'

echo "[CUSTOM-INIT] Configuración modificada con éxito."