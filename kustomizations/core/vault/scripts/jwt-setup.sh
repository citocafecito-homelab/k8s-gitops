#!/bin/sh
set -e

###############################################################################
# Vault post-start bootstrap script
#
# Purpose:
# - Wait until Vault is initialized and unsealed
# - Configure SSH Client Signer (CA)
# - Create an SSH role for Ansible
# - Configure JWT auth for GitHub Actions (keyless)
#
# Assumptions:
# - Vault CLI is available and already authenticated
# - Vault is running locally (loopback)
# - This script may be executed multiple times (idempotent)
###############################################################################

# ---------------------------------------------------------------------------
# Vault environment configuration (local access)
# ---------------------------------------------------------------------------
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_SKIP_VERIFY=true

echo "[INFO] Starting Vault post-start configuration..."

# ---------------------------------------------------------------------------
# Wait until Vault is initialized and unsealed
# ---------------------------------------------------------------------------
# We poll the health endpoint until:
#   - initialized == true
#   - sealed == false
#
# This avoids race conditions during pod/container startup.
# ---------------------------------------------------------------------------
until wget -qO- "$VAULT_ADDR/v1/sys/health" \
    | grep '"initialized":true' \
    | grep '"sealed":false' > /dev/null; do
    echo "[WAIT] Vault is sealed or still starting... retrying in 2s"
    sleep 2
done

echo "[OK] Vault is initialized and unsealed."

# ---------------------------------------------------------------------------
# Enable SSH Secrets Engine (Client Signer)
# ---------------------------------------------------------------------------
# Path: ssh-client-signer
# Using `|| true` to allow safe re-execution
# ---------------------------------------------------------------------------
# vault secrets enable -path=ssh-client-signer ssh || true

# ---------------------------------------------------------------------------
# Configure SSH CA
# ---------------------------------------------------------------------------
# Generates a signing key if it does not already exist
# ---------------------------------------------------------------------------
vault write ssh-client-signer/config/ca \
    generate_signing_key=true || true

# ---------------------------------------------------------------------------
# Create SSH role for Ansible client certificates
# ---------------------------------------------------------------------------
# - Signs user SSH keys
# - Allows any user (validated via JWT auth)
# - Short TTL for security
# ---------------------------------------------------------------------------
vault write ssh-client-signer/roles/ansible-role - <<'EOF'
{
    "algorithm_signer": "rsa-sha2-256",
    "allow_user_certificates": true,
    "allowed_users": "*",
    "allowed_extensions": "permit-pty,permit-port-forwarding",
    "default_extensions": {
    "permit-pty": ""
    },
    "key_type": "ca",
    "default_user": "barista",
    "ttl": "30m"
}
EOF

# ---------------------------------------------------------------------------
# Enable JWT authentication (GitHub Actions)
# ---------------------------------------------------------------------------
# vault auth enable jwt || true

# ---------------------------------------------------------------------------
# Configure GitHub OIDC trust
# ---------------------------------------------------------------------------
# This establishes GitHub Actions as a trusted identity provider
# ---------------------------------------------------------------------------
vault write auth/jwt/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com" || true

# ---------------------------------------------------------------------------
# Define policy allowing SSH certificate signing
# ---------------------------------------------------------------------------
# vault policy write ssh-signer - <<'EOF'
# path "ssh-client-signer/sign/ansible-role" {
#   capabilities = ["update"]
# }
# EOF

# ---------------------------------------------------------------------------
# Create JWT role bound to GitHub repositories
# ---------------------------------------------------------------------------
# - Repository-based trust (glob)
# - Short-lived tokens
# - No static secrets
# ---------------------------------------------------------------------------
vault write auth/jwt/role/github-ansible-role - <<'EOF'
{
    "role_type": "jwt",
    "user_claim": "actor",
    "bound_claims_type": "glob",
    "bound_claims": {
    "repository": "citocafecito-homelab/*"
    },
    "bound_audiences": [
    "http://vault.core.svc.cluster.local",
    "https://github.com/citocafecito-homelab"
    ],
    "policies": [
    "citocafecito-readonly",
    "ssh-signer"
    ],
    "ttl": "10m"
}
EOF

echo "[SUCCESS] Vault JWT auth and SSH CA configuration completed."