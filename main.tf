// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// Using pessimistic version locking for all versions
// ----------------------------------------------------------------------------




locals{
  external_vault = var.vault_url != "" ? true : false

}

module "jx" {
  source = "./modules/jx"

  gcp_project                = var.gcp_project
  cluster_name               = var.cluster_name
  cluster_id                 = var.cluster_id
  bucket_location            = var.bucket_location
  jenkins_x_namespace        = var.jenkins_x_namespace
  force_destroy              = var.force_destroy


  create_ui_sa = var.create_ui_sa
  jx2          = var.jx2
  content      = local.content

  jx_git_url              = var.jx_git_url
  jx_bot_username         = var.jx_bot_username
  jx_bot_token            = var.jx_bot_token
  jx_git_operator_version = var.jx_git_operator_version

  kuberhealthy = var.kuberhealthy
}

// ----------------------------------------------------------------------------
// Setup all required resources for using the  bank-vaults operator
// See https://github.com/banzaicloud/bank-vaults
// ----------------------------------------------------------------------------
module "vault" {
  count  = !var.gsm ? 1 : 0
  source = "./modules/vault"

  gcp_project         = var.gcp_project
  cluster_name        = var.cluster_name
  cluster_id          = var.cluster_id
  bucket_location     = var.bucket_location
  jenkins_x_namespace = module.jx.jenkins_x_namespace
  force_destroy       = var.force_destroy
  external_vault      = local.external_vault
  jx2                 = var.jx2
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Google Secrets Manager
// See https://cloud.google.com/secret-manager
// ----------------------------------------------------------------------------
module "gsm" {
  count  = var.gsm && !var.jx2 ? 1 : 0
  source = "./modules/gsm"

  gcp_project  = var.gcp_project
  cluster_name = var.cluster_name
  cluster_id   = var.cluster_id
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Velero for cluster backups
// ----------------------------------------------------------------------------
module "backup" {
  source = "./modules/backup"

  enable_backup       = var.enable_backup
  gcp_project         = var.gcp_project
  cluster_name        = var.cluster_name
  cluster_id          = var.cluster_id
  bucket_location     = var.bucket_location
  jenkins_x_namespace = module.jx.jenkins_x_namespace
  force_destroy       = var.force_destroy
  jx2                 = var.jx2
}

// ----------------------------------------------------------------------------
// Setup ExternalDNS
// TODO: remove parent_domain & parent_domain_gcp_project when their deprecations are complete
// ----------------------------------------------------------------------------
module "dns" {
  source = "./modules/dns"

  gcp_project                     = var.gcp_project
  cluster_name                    = var.cluster_name
  apex_domain                     = var.apex_domain != "" ? var.apex_domain : var.parent_domain
  jenkins_x_namespace             = module.jx.jenkins_x_namespace
  jx2                             = var.jx2
  subdomain                       = var.subdomain
  apex_domain_gcp_project         = var.apex_domain_gcp_project != "" ? var.apex_domain_gcp_project : (var.parent_domain_gcp_project != "" ? var.parent_domain_gcp_project : var.gcp_project)
  apex_domain_integration_enabled = var.apex_domain_integration_enabled

  depends_on = [
    module.jx
  ]
}

// ----------------------------------------------------------------------------
// Setup Boot Cluster Charts
//
// ----------------------------------------------------------------------------

module "jx-boot" {
  source        = "./modules/jx-boot"
  depends_on    = [module.jx]
  install_vault = !var.gsm ? true : false
}

// ----------------------------------------------------------------------------
// Let's generate jx-requirements.yml
// ----------------------------------------------------------------------------
locals {
  requirements_file = var.jx2 ? "${path.module}/modules/jx-requirements.yml.tpl" : "${path.module}/modules/jx-requirements-v3.yml.tpl"
  interpolated_content = templatefile(local.requirements_file, {
    gcp_project                 = var.gcp_project
    zone                        = var.cluster_location
    cluster_name                = var.cluster_name
    git_owner_requirement_repos = var.git_owner_requirement_repos
    dev_env_approvers           = var.dev_env_approvers
    lets_encrypt_production     = var.lets_encrypt_production
    // Storage buckets
    log_storage_url        = module.jx.log_storage_url
    report_storage_url     = module.jx.report_storage_url
    repository_storage_url = module.jx.repository_storage_url
    backup_bucket_url      = module.backup.backup_bucket_url
    // Vault
    external_vault  = local.external_vault
    vault_bucket    = length(module.vault) > 0 ? module.vault[0].vault_bucket_name : ""
    vault_key       = length(module.vault) > 0 ? module.vault[0].vault_key : ""
    vault_keyring   = length(module.vault) > 0 ? module.vault[0].vault_keyring : ""
    vault_name      = length(module.vault) > 0 ? module.vault[0].vault_name : ""
    vault_sa        = length(module.vault) > 0 ? module.vault[0].vault_sa : ""
    vault_url       = var.vault_url
    vault_installed = !var.gsm ? true : false
    // Velero
    enable_backup    = var.enable_backup
    velero_sa        = module.backup.velero_sa
    velero_namespace = module.backup.backup_bucket_url != "" ? var.velero_namespace : ""
    velero_schedule  = var.velero_schedule
    velero_ttl       = var.velero_ttl
    // DNS
    // TODO: remove parent_domain when its deprecations is complete: domain_enabled = var.apex_domain != "" ? true : false
    domain_enabled = var.apex_domain != "" ? true : (var.parent_domain != "" ? true : false)
    // TODO: replace with the following when parent_domain deprecations is complete: apex_domain  = var.apex_domain
    apex_domain = var.apex_domain != "" ? var.apex_domain : var.parent_domain
    subdomain   = var.subdomain
    tls_email   = var.tls_email
    // Kuberhealthy
    kuberhealthy = var.kuberhealthy

    version_stream_ref = var.version_stream_ref
    version_stream_url = var.version_stream_url
    webhook            = var.webhook
  })

  split_content   = split("\n", local.interpolated_content)
  compact_content = compact(local.split_content)
  content         = join("\n", local.compact_content)
}
