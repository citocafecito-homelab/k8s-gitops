# 🏗️ Kubernetes GitOps Homelab Cluster

English Documentation. Also available in:

[![es](https://img.shields.io/badge/lang-es-yellow.svg)](README.es.md)

[![Deploy Kustomizations](https://github.com/citocafecito-homelab/k8s-gitops/actions/workflows/kustomizations.yaml/badge.svg)](https://github.com/citocafecito-homelab/k8s-gitops/actions/workflows/kustomizations.yaml)

## 📂 Cluster Organization

The cluster logic is divided into service layers within the `kustomizations/` directory:

### 🛡️ Core & Security

Fundamental, cross-cutting services for operations and data protection.

- `Vault` / `Infisical`: Centralized management of secrets and configurations.
- `Cloudflared`: Secure tunnels to expose services without opening ports.
- `Chromium`: Isolated browser instance for automated tasks.
- `ARC`: Self-hosted GitHub Actions runners for workflow automation.

### 🌐 Networking & Access

- `MetalLB`: Load balancer for assigning local IPs to services.
- `Pi-Hole`: Ad blocking and local DNS management.
- `External-DNS`: Automatic synchronization of DNS records in Pi-Hole.

### 🏠 Home Automation (home-assistant)

Home control center with extended support for multiple protocols:

- Protocols: `Zigbee2MQTT`, `Z-Wave (in progress)`, `Matter`, `Thread`.
- Voice & Audio: `Whisper`, `Piper` (local STT/TTS), `Music Assistant`.
- Integrations: `Ring-MQTT`, `Mosquitto` (MQTT Broker).

### 🎬 Streaming & Media

Complete stack for multimedia content management:

- Servers: `Jellyfin` A.K.A Habiflix, `Navidrome` A.K.A. HabiMusic.
- Management (Arrs): `Sonarr`, `Radarr`, `Lidarr`, `Prowlarr`, `Bazarr`.
- Downloads: `Deluge`, `Transmission`, `NZBGet`.
- Utilities: `Flaresolverr`, `Suwayomi`, `Lidify`.

### 📦 Storage & Utilities

- `Nextcloud` / `MyDrive`: Private cloud storage and collaboration.
- `Minio` (deprecated) / `Garage` (in progress): S3-compatible object storage.
- Tools: `Reactive Resume` (CV management), `Wiki.js` (documentation), `Excalidraw`.
- Download Managers: `pyLoad`.

## 🔒 Security Notes for Study

If you’re reviewing this repo to learn:

- Layer separation: Note how each application has its own namespace or folder with constrained resources (HPA/VPA).
- Persistence: Decoupled PersistentVolumeClaims are used to ensure data survives pod restarts.
- Secrets: You won’t find passwords here. The use of Sealed Secrets or injection via Vault/Infisical is recommended.