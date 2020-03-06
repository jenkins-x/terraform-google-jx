terraform {
  required_version = "~> 0.12.0"
}

module "jx" {
  source = "./jx"

  gcp_project   = var.gcp_project
  zone          = var.zone
  cluster_name  = var.cluster_name
  parent_domain = var.parent_domain
}

// ----------------------------------------------------------------------------
// Let's generate jx-requirements.yml 
// ----------------------------------------------------------------------------
resource "local_file" "jx-requirements" {
  content = templatefile("${path.module}/jx-requirements.yaml.tpl", {
    gcp_project                 = module.jx.gcp_project
    zone                        = module.jx.zone
    cluster_name                = module.jx.cluster_name
    git_owner_requirement_repos = var.git_owner_requirement_repos
    dev_env_approvers           = var.dev_env_approvers
    // Storage buckets
    log_storage_url        = module.jx.log_storage_url
    report_storage_url     = module.jx.report_storage_url
    repository_storage_url = module.jx.repository_storage_url
    backup_bucket_url      = module.jx.backup_bucket_url
    // Vault
    vault_bucket  = module.jx.vault_bucket_name
    vault_key     = module.jx.vault_key
    vault_keyring = module.jx.vault_keyring
    vault_name    = module.jx.vault_name
    vault_sa      = module.jx.vault_sa
    // Velero
    velero_sa        = module.jx.velero_sa
    velero_namespace = module.jx.backup_bucket_url != "" ? var.velero_namespace : ""
    velero_schedule  = var.velero_schedule
    velero_ttl       = var.velero_ttl
    // DNS
    domain_enabled = var.parent_domain != "" ? true : false
    parent_domain  = var.parent_domain

    version_stream_ref = var.version_stream_ref
    version_stream_url = var.version_stream_url
  })
  filename = "${path.module}/jx-requirements.yaml"
}

// ----------------------------------------------------------------------------
// Let's make sure `jx boot` can connect to the cluster for local booting 
// ----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.jx.cluster_name} --zone=${module.jx.cluster_location} --project=${var.gcp_project}"
  }
}
