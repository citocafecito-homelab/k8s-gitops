{{- with secret "secret/data/kite" -}}
superUser:
  username: "admin"
  password: "admin"

clusters:
  - name: citocafecito
    inCluster: true
    description: "Citocafecito In Cluster setup"
    default: true
    prometheusURL: "http://prometheus-k8s.monitoring.svc.cluster.local:9090"

# oauth:
#   - name: google
#     clientId: "xxx.apps.googleusercontent.com"
#     clientSecret: "client-secret-value"
#     issuer: "https://accounts.google.com"
#     scopes: "openid,profile,email"
#     usernameClaim: "email"
#     groupsClaim: "groups"
#     enabled: true

# ldap:
#   enabled: true
#   serverUrl: "ldaps://ldap.example.com:636"
#   bindDn: "cn=svc-kite,ou=services,dc=example,dc=com"
#   bindPassword: "bind-password"
#   userBaseDn: "ou=users,dc=example,dc=com"
#   userFilter: "(uid=%s)"
#   usernameAttribute: "uid"
#   displayNameAttribute: "cn"
#   groupBaseDn: "ou=groups,dc=example,dc=com"
#   groupFilter: "(member=%s)"
#   groupNameAttribute: "cn"

# ai:
#   enabled: true
#   provider: openai
#   model: gpt-4o-mini
#   apiKey: "${AI_API_KEY}"
#   baseUrl: "https://api.openai.com/v1"
#   maxTokens: 16384

# rbac:
#   roles:
#     - name: admin
#       description: "Administrator role with full access"
#       clusters: ["*"]
#       namespaces: ["*"]
#       resources: ["*"]
#       verbs: ["*"]
#     - name: viewer
#       description: "Read-only access"
#       clusters: ["*"]
#       namespaces: ["*"]
#       resources: ["*"]
#       verbs: ["get", "log"]
#     - name: dev-team
#       description: "Development team access"
#       clusters: ["dev-*", "staging-*"]
#       namespaces: ["*"]
#       resources: ["*"]
#       verbs: ["get", "create", "update", "delete", "log"]
#   roleMapping:
#     - name: admin
#       users: ["alice", "bob"]
#       oidcGroups: ["platform-admins"]
#     - name: viewer
#       users: ["*"]
#     - name: dev-team
#       oidcGroups: ["developers"]
{{- end }}


