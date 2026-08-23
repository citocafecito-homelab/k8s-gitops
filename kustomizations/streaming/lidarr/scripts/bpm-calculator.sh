#!/bin/bash

# Lidarr usa variables de entorno para pasar la ruta del archivo.
# Usamos lidarr_trackfile_path que contiene la ruta absoluta del archivo importado.
FILE="${lidarr_trackfile_path}"

if [ "$lidarr_eventtype" == "Test" ]; then
echo "Prueba de conexión exitosa con Lidarr."
exit 0
fi

# Verificación de seguridad: si la variable está vacía, no hace nada.
if [ -z "$FILE" ]; then
echo "Error: No se recibió la ruta del archivo desde Lidarr."
exit 1
fi

# 1. Calcular BPM con aubio
# Se procesa un solo archivo a la vez, eliminando la necesidad del bucle 'find'.
BPM=$(aubio tempo "$FILE" 2>/dev/null | head -n 1 | awk '{print int($1)}')

# Validar que se obtuvo un valor numérico
if [ -z "$BPM" ] || [ "$BPM" -eq 0 ]; then
echo "Saltando: No se pudo detectar BPM para $FILE"
exit 0 # Salida exitosa para no bloquear el flujo de Lidarr[cite: 250, 251].
fi

echo "Procesando [$BPM BPM]: $FILE"

# 2. Asignar etiquetas según la extensión del archivo
case "$FILE" in
*.m4a)
    AtomicParsley "$FILE" --bpm "$BPM" --overWrite
    ;;
*.flac)
    metaflac --remove-tag=BPM --set-tag="BPM=$BPM" "$FILE"
    ;;
*.mp3)
    mid3v2 --TBP "$BPM" "$FILE" > /dev/null
    ;;
esac

echo "¡BPM asignado correctamente!"