#!/bin/sh

MQTT_USER="${MQTT_USER:-}"
MQTT_PASS="${MQTT_PASS:-}"

NODE_NAME="${NODE_NAME:-unknown-node}"
NODE_ID=$(echo "$NODE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/_/g')

AUTH_FLAGS=""
if [ -n "$MQTT_USER" ]; then
  AUTH_FLAGS="-u $MQTT_USER -P $MQTT_PASS"
fi

STORAGE_BASE="/host_storage"

if [ ! -d "$STORAGE_BASE" ]; then
  exit 0
fi

ALL_FOLDERS=$(find "$STORAGE_BASE" -mindepth 1 -maxdepth 2 -type d 2>/dev/null)

for FOLDER_PATH in $ALL_FOLDERS; do
  REL_PATH=$(echo "$FOLDER_PATH" | sed "s|^$STORAGE_BASE||")
  CLEAN_ID=$(echo "$REL_PATH" | tr '/' '_' | sed 's/^_//' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/_/g')
  
  if [ -z "$CLEAN_ID" ]; then continue; fi

  TOPIC_BASE="homeassistant/sensor/storage_${NODE_ID}_${CLEAN_ID}"
  STATE_TOPIC="${TOPIC_BASE}/state"

  DISCOVERY_SIZE='{
    "name": "'"$NODE_NAME"' - '"$REL_PATH"' Peso",
    "unique_id": "k8s_storage_size_'"$NODE_ID"'_'"$CLEAN_ID"'",
    "state_topic": "'"$STATE_TOPIC"'",
    "value_template": "{{ value_json.size_mb }}",
    "unit_of_measurement": "MB",
    "device_class": "data_size",
    "state_class": "measurement",
    "icon": "mdi:folder-information",
    "device": {
      "identifiers": ["k8s_storage_node_'"$NODE_ID"'"],
      "name": "K8s Storage '"$NODE_NAME"'",
      "model": "DaemonSet Storage Watcher",
      "manufacturer": "Kubernetes"
    }
  }'
  mosquitto_pub $AUTH_FLAGS -h "$MQTT_HOST" -t "${TOPIC_BASE}_size/config" -m "$DISCOVERY_SIZE" -r 2>/dev/null

  DISCOVERY_FILES='{
    "name": "'"$NODE_NAME"' - '"$REL_PATH"' Archivos",
    "unique_id": "k8s_storage_files_'"$NODE_ID"'_'"$CLEAN_ID"'",
    "state_topic": "'"$STATE_TOPIC"'",
    "value_template": "{{ value_json.files }}",
    "unit_of_measurement": "archivos",
    "state_class": "measurement",
    "icon": "mdi:file-multiple",
    "device": {
      "identifiers": ["k8s_storage_node_'"$NODE_ID"'"],
      "name": "K8s Storage '"$NODE_NAME"'",
      "model": "DaemonSet Storage Watcher",
      "manufacturer": "Kubernetes"
    }
  }'
  mosquitto_pub $AUTH_FLAGS -h "$MQTT_HOST" -t "${TOPIC_BASE}_files/config" -m "$DISCOVERY_FILES" -r 2>/dev/null

  FILES=$(ls -1q "$FOLDER_PATH" 2>/dev/null | wc -l)
  BYTES=$(du -sb "$FOLDER_PATH" 2>/dev/null | cut -f1)
  
  if [ -z "$BYTES" ]; then BYTES=0; fi
  SIZE_MB=$((BYTES / 1024 / 1024))

  PAYLOAD="{\"size_mb\": $SIZE_MB, \"files\": $FILES}"
  mosquitto_pub $AUTH_FLAGS -h "$MQTT_HOST" -t "$STATE_TOPIC" -m "$PAYLOAD" 2>/dev/null
done