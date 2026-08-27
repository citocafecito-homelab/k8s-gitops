# migrate running vault operator migrate -config /vault/config/migrate.hcl
storage_source "file" {
    path = "/vault/data"
}

storage_destination "s3" {
    bucket              = "vault"
    endpoint            = "http://garage.storage.svc.cluster.local:3900"
    region              = "garage"
    s3_force_path_style = "true"
}