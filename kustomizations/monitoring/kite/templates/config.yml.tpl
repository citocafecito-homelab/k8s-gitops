{{- with secret "secret/data/kite" -}}
superUser:
  username: "{{ .Data.data.ADMIN_USERNAME }}"
  password: "{{ .Data.data.ADMIN_PASSWORD }}"

clusters:
  - name: citocafecito
    inCluster: true
    description: "Citocafecito In Cluster setup"
    default: true
    prometheusURL: "http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"

oauth:
  - name: google
    clientId: "{{ .Data.data.OAUTH_GOOGLE_CLIENT_ID }}"
    clientSecret: "{{ .Data.data.OAUTH_GOOGLE_CLIENT_SECRET }}"
    issuer: "https://accounts.google.com"
    scopes: "openid,profile,email"
    usernameClaim: "email"
    groupsClaim: ""
    enabled: true

  - name: github
    clientId: "{{ .Data.data.OAUTH_GITHUB_CLIENT_ID }}"
    clientSecret: "{{ .Data.data.OAUTH_GITHUB_CLIENT_SECRET }}"
    authUrl: "https://github.com/login/oauth/authorize"
    tokenUrl: "https://github.com/login/oauth/access_token"
    userInfoUrl: "https://api.github.com/user"
    scopes: "read:user,user:email,read:org"
    usernameClaim: "login"
    groupsClaim: "groups"
    allowedGroups: "citocafecito-homelab"


# ai:
#   enabled: true
#   provider: openai
#   model: gpt-4o-mini
#   apiKey: "${AI_API_KEY}"
#   baseUrl: "https://api.openai.com/v1"
#   maxTokens: 16384

rbac:
  {{- with secret "secret/data/kite/rbac-roles" }}
  roles:
  {{- range $name, $role := .Data.data }}
    - name: {{ $name }}
      description: "{{ $role.description }}"
      clusters: {{ $role.clusters | toJSON }}
      namespaces: {{ $role.namespaces | toJSON }}
      resources: {{ $role.resources | toJSON }}
      verbs: {{ $role.verbs | toJSON }}
  {{- end }}
  {{- end }}
  
  {{- with secret "secret/data/kite/rbac-mapping" }}
  roleMapping:
  {{- range $name, $map := .Data.data }}
    - name: {{ $name }}
      users: "{{ $map.users | toJSON }}"
      oidcGroups: {{ $map.groups | toJSON }}
  {{- end }}
  {{- end }}
{{- end }}