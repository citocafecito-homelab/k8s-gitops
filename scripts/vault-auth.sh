vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://kubernetes.default.svc.cluster.local:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault read auth/kubernetes/config

vault write auth/kubernetes/login role=vault jwt="$TOKEN_REVIEWER_JWT"

vault write auth/jwt/role/github-ansible-role - <<EOF
{
  "role_type": "jwt",
  "user_claim": "actor",
  "bound_claims_type": "glob",
  "bound_claims": {
    "repository": "citocafecito-homelab/*"
  },
  "bound_audiences": "https://vault.core.svc.cluster.local",
  "policies": ["citocafecito-readonly", "ssh-signer"],
  "ttl": "10m"
}
EOF