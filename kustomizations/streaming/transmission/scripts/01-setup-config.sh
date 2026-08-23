#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md

source /scripts/common.sh

echo "[CUSTOM-INIT] Configurando Transmission..."

JSON_FILE="/config/settings.json"
PORT_FILE="/config/forwarded_port"

# Asegurar que la carpeta exista y que haya un JSON válido de base
mkdir -p /config
if [ ! -f "$JSON_FILE" ] || [ ! -s "$JSON_FILE" ]; then
    echo "{}" > "$JSON_FILE"
fi

PORT=51413
if [ -f "$PORT_FILE" ] && [ -s "$PORT_FILE" ]; then
    PORT=$(cat "$PORT_FILE" | tr -d '\r\n')
    echo "[CUSTOM-INIT] Puerto forwarding detectado: $PORT"
else
    echo "[CUSTOM-INIT] No se encontró $PORT_FILE, usando puerto por defecto: $PORT"
fi

tmp=$(mktemp)

jq \
  --arg download_dir "/downloads" \
  --argjson script_added_enabled true \
  --arg script_added_fn "/scripts/torrent-added.sh" \
  --argjson script_done_enabled false \
  --arg script_done_fn "/scripts/torrent-finished.sh" \
  --argjson script_seeding_enabled true \
  --arg script_seeding_fn "/scripts/torrent-completed.sh" \
  --argjson incomplete_enabled false \
  --argjson rename_partial false \
  --argjson ratio_limit 3.0 \
  --argjson ratio_enabled true \
  --argjson download_queue_enabled false \
  --argjson seed_queue_enabled false \
  --argjson download_queue_size 999 \
  --argjson seed_queue_size 999 \
  --argjson peer_port_random false \
  --argjson peer_port $PORT \
  --argjson peer_limit 20 \
  '.["download-dir"] = $download_dir |
   .["script-torrent-added-enabled"] = $script_added_enabled |
   .["script-torrent-added-filename"] = $script_added_fn |
   .["script-torrent-done-enabled"] = $script_done_enabled |
   .["script-torrent-done-filename"] = $script_done_fn |
   .["script-torrent-done-seeding-enabled"] = $script_seeding_enabled |
   .["script-torrent-done-seeding-filename"] = $script_seeding_fn |
   .["incomplete-dir-enabled"] = $incomplete_enabled |
   .["rename-partial-files"] = $rename_partial |
   .["ratio-limit"] = $ratio_limit |
   .["ratio-limit-enabled"] = $ratio_enabled |
   .["download-queue-enabled"] = $download_queue_enabled |
   .["seed-queue-enabled"] = $seed_queue_enabled |
   .["download-queue-size"] = $download_queue_size |
   .["seed-queue-size"] = $seed_queue_size |
   .["peer-port-random-on-start"] = $peer_port_random |
   .["peer-limit-per-torrent"] = $peer_limit' \
  "$JSON_FILE" > "$tmp" && mv "$tmp" "$JSON_FILE"

echo "[CUSTOM-INIT] Configuración modificada con éxito."

send_ntfy "Transmission - Init" \
          "Configuración de inicio configuraca con éxito" \
          "seedling,lock" \
          "low"