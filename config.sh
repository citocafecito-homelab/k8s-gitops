#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="tinytuya.json"

API_REGION="${API_REGION:-us}"
DEVICE_ID="${DEVICE_ID:-eb2dd1a5b779492c02o4qy}"

cat > "$OUTPUT_FILE" <<EOF
{
    "apiKey": "${TUYA_CLOUD_ID}",
    "apiSecret": "${TUYA_CLOUD_SECRET}",
    "apiRegion": "${API_REGION}",
    "apiDeviceID": "${DEVICE_ID}"
}
EOF

echo "✅ Config file created at: $OUTPUT_FILE"