#!/bin/bash
# See more https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md

source /scripts/common.sh

echo "--- Detectado Alpine: Instalando con apk ---"
# bpm-tools no está en los repos oficiales de Alpine, 
# pero podemos usar aubio y flac que son los que necesitas para los FLAC.
apk add --no-cache flac aubio aubio-tools
echo "--- Instalación finalizada ---"