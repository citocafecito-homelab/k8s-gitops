#!/bin/sh
set -e

MARKER="/var/lib/vault-ssh-ca.done"
CA_PATH="/etc/ssh/trusted-user-ca-keys.pem"
SSHD_CONFIG="/etc/ssh/sshd_config"
VAULT_ADDR="http://vault.lan:8200"

if [ -f "$MARKER" ]; then
  echo "Vault SSH CA already configured on this node."
  exit 0
fi

echo "Installing Vault SSH CA..."

# Descargar la clave pública del CA desde Vault
curl -sf \
  "$VAULT_ADDR/v1/ssh-client-signer/config/ca" \
  | jq -r '.data.public_key' \
  > "$CA_PATH"

if [ ! -s "$CA_PATH" ]; then
  echo "Failed to download SSH CA public key from Vault"
  exit 1
fi

chmod 0644 "$CA_PATH"

# Configurar sshd para confiar en el CA
if ! grep -q "^TrustedUserCAKeys" "$SSHD_CONFIG"; then
  echo "TrustedUserCAKeys $CA_PATH" >> "$SSHD_CONFIG"
fi

# Reiniciar el servicio SSH
if command -v systemctl >/dev/null 2>&1; then
  systemctl restart ssh || systemctl restart sshd
else
  service ssh restart || service sshd restart
fi

touch "$MARKER"
echo "Vault SSH CA installation completed."
