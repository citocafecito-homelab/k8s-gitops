#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <ruta_de_la_carpeta>"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: La ruta '$TARGET_DIR' no existe o no es un directorio."
    exit 1
fi

echo "Buscando manifiestos recursivamente en: $TARGET_DIR"
echo "--------------------------------------------------"

COUNT=0

while IFS= read -r file; do
    echo "[+] Procesando: $file"
    
    # La opción -s (--sort-keys) ordena alfabéticamente las propiedades
    yq -y -s -i '
      if .kind == "Deployment" or .kind == "StatefulSet" or .kind == "DaemonSet"
      then .spec.template.spec.enableServiceLinks = false
      else .
      end
    ' "$file"
    
    COUNT=$((COUNT + 1))
done < <(find "$TARGET_DIR" -type f \( -name "*.yaml" -o -name "*.yml" \) -exec grep -lE 'kind:\s*(Deployment|StatefulSet|DaemonSet)' {} +)

echo "--------------------------------------------------"
echo "¡Proceso finalizado! Se actualizaron $COUNT archivos ordenados alfabéticamente."