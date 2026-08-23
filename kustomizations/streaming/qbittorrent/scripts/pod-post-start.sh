#!/bin/bash
# /scripts/pod-post-start.sh

source /scripts/common.sh

sleep 10
echo "[POST-START] Ejecutando inicio del Pod..."

/bin/bash /scripts/check-port-daemon.sh

echo "[POST-START] Procesos iniciales iniciados correctamente."