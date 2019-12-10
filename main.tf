terraform {
  required_version = ">= 0.12.0"
}

module "jx" {
  source = "./jx"

  gcp_project   = "terraform-test"
  region        = "europe-west1"
  zone          = "europe-west1-b"
  cluster_name  = "test-cluster"
  parent_domain = "test.com"

  
}

resource "local_file" "jx-requirements" {
  content = templatefile("${path.module}/jx-requirements.yaml.tpl", {
    cluster_name = module.jx.cluster_name
    gcp_project  = module.jx.gcp_project
    zone  = module.jx.zone
    lts_bucket = module.jx.lts_bucket_url
    backup_bucket = module.jx.backup_bucket_url
    vault_bucket = module.jx.vault_bucket_name
    vault_key =  ""
    vault_keyring = ""
    vault_name = ""
    vault_sa = ""
  })
  filename = "${path.module}/jx-requirements.yaml"
}

