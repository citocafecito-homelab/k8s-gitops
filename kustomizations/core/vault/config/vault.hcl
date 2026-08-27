ui              = true
disable_mlock   = true
cluster_name    = "kubernetes"

listener "tcp" {
    address     = "0.0.0.0:8200"
    tls_disable = true
}

storage "s3" {
    bucket              = "vault"
    endpoint            = "http://garage.storage.svc.cluster.local:3900"
    region              = "garage"
    s3_force_path_style = "true"
}

telemetry {
    disable_hostname = true
    prometheus_retention_time = "12h"
}

api_addr = "http://vault.core.svc.cluster.local:8200"