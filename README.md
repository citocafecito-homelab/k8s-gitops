# K8s GitOps

[![Deploy Kustomizations](https://github.com/citocafecito-homelab/k8s-gitops/actions/workflows/main.yml/badge.svg)](https://github.com/citocafecito-homelab/k8s-gitops/actions/workflows/main.yml)

| GitOps repository for managing Kubernetes deployments of `Citocafecito homelab` applications.

The repository contains folders with manifests and configurations intended for one-off use or specific scenarios:

- [k8s/](k8s): Base manifests for manual or ad-hoc deployments
- [kustomizations/](kustomizations): Kustomize overlays and automated deployments via GitHub Actions
  - [core/](kustomizations/core): Core infrastructure and essential services for the cluster
  - [media/](kustomizations/media): Media-related applications (e.g., Plex, Jellyfin)
  - [netallb/](kustomizations/netallb): Network load balancer configurations
  - [monitoring/](kustomizations/monitoring): Monitoring and observability tools (e.g., Prometheus, Grafana)
  - [networking/](kustomizations/networking): Network policies, ingress controllers, and DNS
  - [storage/](kustomizations/storage): Persistent volume claims, storage classes, and backups
  - [streaming/](kustomizations/streaming): Streaming applications and services
- [scripts/](scripts): Utility scripts for deployment, maintenance, or one-off tasks

⚙️ Designed for experimental and support purposes within my homelab Kubernetes setup, deployed and managed through GitOps workflows.

## Powered By

- Kubernetes 🟦
- Kustomize 🛠️
- direnv 🌱
- Tuya 🔌
- Infisical 🔑
