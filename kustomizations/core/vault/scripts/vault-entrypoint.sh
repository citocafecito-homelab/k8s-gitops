#!/bin/sh
set -e

VAULT_CONFIG="/vault/config/vault.hcl"

echo "🚀 Starting Vault server..."
vault server -config="$VAULT_CONFIG" &
VAULT_PID=$!

sleep 2

# Check Vault seal status (without using jq)
SEALED=$(vault status -format=json | grep -o '"sealed":[^,]*' | cut -d':' -f2 | tr -d '[:space:]')

if [ "$SEALED" = "true" ]; then
    echo "🔒 Vault is sealed. Attempting to unseal..."
    vault operator unseal "$UNSEAL_KEY"
elif [ "$SEALED" = "false" ]; then
    echo "✅ Vault is already unsealed."
else
    echo "⚠️ Unable to determine Vault status (value: '$SEALED')."
    exit 1
fi

# Configure Kubernetes authentication method
echo "🔧 Configuring Kubernetes authentication..."
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://kubernetes.default.svc.cluster.local:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

echo "✅ Vault initialized and configured. Running in foreground..."

# Keep Vault running in the foreground
wait $VAULT_PID