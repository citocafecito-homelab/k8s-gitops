TOKEN_REVIEWER_JWT=$(kubectl create token vault -n core)

KUBE_HOST=$(kubectl get svc kubernetes -o jsonpath='{.spec.clusterIP}')

KUBE_CA_CERT=$(kubectl get secret $(kubectl get sa vault-auth -n core -o jsonpath='{.secrets[0].name}') -n core -o jsonpath='{.data.ca\.crt}' | base64 --decode)

# Si se cae la autenticación co vault ejecutar dentro de vault
vault write auth/kubernetes/config \
    token_reviewer_jwt="$TOKEN_REVIEWER_JWT" \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert="$KUBE_CA_CERT" \
    disable_iss_validation=false \
    issuer="https://kubernetes.default.svc.cluster.local"


vault read auth/kubernetes/config

vault write auth/kubernetes/login role=vault jwt="$TOKEN_REVIEWER_JWT"