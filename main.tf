terraform {
  required_version = ">= 0.12.0"
}

module "jx" {
  source = "./jx"

  gcp_project   = var.gcp_project
  region        = var.region
  zone          = var.zone
  cluster_name  = var.cluster_name
  parent_domain = "test.com"


}

resource "local_file" "jx-requirements" {
  content = templatefile("${path.module}/jx-requirements.yaml.tpl", {
    cluster_name  = module.jx.cluster_name
    gcp_project   = module.jx.gcp_project
    zone          = module.jx.zone
    lts_bucket    = module.jx.lts_bucket_url
    backup_bucket = module.jx.backup_bucket_url
    vault_bucket  = module.jx.vault_bucket_name
    vault_key     = module.jx.vault_key
    vault_keyring = module.jx.vault_keyring
    vault_name    = module.jx.vault_name
    vault_sa      = module.jx.vault_sa
  })
  filename = "${path.module}/jx-requirements.yaml"
}

