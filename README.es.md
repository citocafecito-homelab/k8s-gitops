# 🏗️ Kubernetes GitOps Homelab Cluster

Documentación en español. También disponible en:

[![en](https://img.shields.io/badge/lang-en-red.svg)](README.md)

[![Deploy Kustomizations](https://github.com/citocafecito-homelab/k8s-gitops/actions/workflows/kustomizations.yaml/badge.svg)](https://github.com/citocafecito-homelab/k8s-gitops/actions/workflows/kustomizations.yaml)

## 📂 Organización del Cluster

La lógica del cluster se divide en capas de servicio dentro del directorio `kustomizations/`:

### 🛡️ Core & Seguridad

Servicios fundamentales y transversales para la operación y resguardo de datos.

- `Vault` / `Infisical`: Gestión centralizada de secretos y configuraciones.

- `Cloudflared`: Túneles seguros para exposición de servicios sin abrir puertos.

- `Chromium`: Instancia de navegador aislada para tareas automatizadas.

- `ARC`: Runners Autoalojados de Github Actions para automatización de flujos de trabajo.

### 🌐 Networking & Acceso

- `MetalLB`: Balanceador de carga para asignar IPs locales a los servicios.

- `Pi-Hole`: Bloqueo de publicidad y gestión de DNS local.

- `External-DNS`: Sincronización automática de registros DNS en Pi-Hole.

### 🏠 Home Automation (home-assistant)

Centro de control del hogar con soporte extendido para múltiples protocolos:

- Protocolos: `Zigbee2MQTT`, `Z-Wave (en progreso)`, `Matter`, `Thread`.

- Voz y Audio: `Whisper`, `Piper` (STT/TTS local), `Music Assistant`.

- Integraciones: `Ring-MQTT`, `Mosquitto` (MQTT Broker).

### 🎬 Streaming & Media

Stack completo para gestión de contenido multimedia:

- Servidores: `Jellyfin` A.K.A Habiflix, `Navidrome` A.K.A. HabiMusic.

- Gestión (Arrs): `Sonarr`, `Radarr`, `Lidarr`, `Prowlarr`, `Bazarr`.

- Descargas: `Deluge`, `Transmission`, `NZBGet`.

- Utilidades: `Flaresolverr`, `Suwayomi`, `Lidify`.

### 📦 Storage & Utilidades

- `Nextcloud` / `MyDrive`: Almacenamiento y colaboración en la nube privada.

- `Minio` (deprecado) / `Garage` (en progreso): Almacenamiento de objetos compatible con S3.

- Herramientas: `Reactive Resume` (gestión de CV), `Wiki.js` (documentación), `Excalidraw`.

- Gestores de Descargas: `pyLoad`.

## 🔒 Notas de Seguridad para el Estudio

Si estás revisando este repo para aprender:

- Separación de capas: Nota cómo cada aplicación tiene su propio namespace o carpeta con recursos limitados (HPA/VPA).

- Persistencia: Se utilizan PersistentVolumeClaims desacoplados para asegurar que los datos sobrevivan a reinicios de pods.

- Secretos: No encontrarás contraseñas aquí. Se recomienda el uso de Sealed Secrets o inyección vía Vault/Infisical.