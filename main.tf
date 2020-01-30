terraform {
  required_version = ">= 0.12.0"
}

module "jx" {
  source = "./jx"

  gcp_project   = var.gcp_project
  region        = var.region
  zone          = var.zone
  cluster_name  = var.cluster_name
  parent_domain = var.parent_domain


}

resource "local_file" "jx-requirements" {
  content = templatefile("${path.module}/jx-requirements.yaml.tpl", {
    gcp_project   = module.jx.gcp_project
    zone          = module.jx.zone
    cluster_name  = module.jx.cluster_name
    lts_bucket    = module.jx.lts_bucket_url
    backup_bucket = module.jx.backup_bucket_url
    vault_bucket  = module.jx.vault_bucket_name
    vault_key     = module.jx.vault_key
    vault_keyring = module.jx.vault_keyring
    vault_name    = module.jx.vault_name
    vault_sa      = module.jx.vault_sa
    velero_sa     = module.jx.velero_sa
    // from variables
    domain_enabled     = var.parent_domain != "" ? true : false
    parent_domain      = var.parent_domain
    velero_namespace   = module.jx.backup_bucket_url != "" ? var.velero_namespace : ""
    velero_schedule    = var.velero_schedule
    velero_ttl         = var.velero_ttl
    version_stream_ref = var.version_stream_ref
    version_stream_url = var.version_stream_url
    webhook            = var.webhook
  })
  filename = "${path.module}/jx-requirements.yaml"
}

