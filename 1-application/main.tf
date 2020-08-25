// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// Using pessimistic version locking for all versions
// ----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.0, < 0.14"
}

// ----------------------------------------------------------------------------
// Configure providers
// ----------------------------------------------------------------------------
provider "random" {
  version = ">= 2.2.0"
}

provider "local" {
  version = ">= 1.2.0"
}

provider "null" {
  version = ">= 2.1.0"
}

provider "template" {
  version = ">= 2.1.0"
}

provider "kubernetes" {
  version          = ">= 1.11.0"
  load_config_file = false

  host  = "https://${var.cluster_endpoint}"
  token = var.access_token
  cluster_ca_certificate = base64decode(
    var.cluster_ca_certificate,
  )
}

resource "random_id" "random" {
  byte_length = 6
}

resource "random_pet" "current" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    cluster_name = var.cluster_name
  }
}

locals {
  cluster_name = "${var.cluster_name != "" ? var.cluster_name : random_pet.current.id}"
  # provide backwards compatibility with the deprecated zone variable
  location       = "${var.zone != "" ? var.zone : var.cluster_location}"
  external_vault = var.vault_url != "" ? true : false
}

// ----------------------------------------------------------------------------
// Create Kubernetes cluster
// ----------------------------------------------------------------------------
module "cluster" {
  source = "./modules/cluster"

  build_controller_sa_email = var.build_controller_sa_email
  kaniko_sa_email           = var.kaniko_sa_email
  tekton_sa_email           = var.tekton_sa_email
  jxui_sa_email             = var.jxui_sa_email
  jenkins_x_namespace       = var.jenkins_x_namespace

  create_ui_sa = var.create_ui_sa
  jx2          = var.jx2
  content      = local.content
}

// ----------------------------------------------------------------------------
// Setup all required resources for using the  bank-vaults operator
// See https://github.com/banzaicloud/bank-vaults
// ----------------------------------------------------------------------------
module "vault" {
  source = "./modules/vault"

  vault_sa_email      = var.vault_sa_email
  jenkins_x_namespace = module.cluster.jenkins_x_namespace
  external_vault      = local.external_vault
  jx2                 = var.jx2
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Velero for cluster backups
// ----------------------------------------------------------------------------
module "backup" {
  source = "./modules/backup"

  enable_backup   = var.enable_backup
  velero_sa_email = var.backup_velero_sa_email
}

// ----------------------------------------------------------------------------
// Setup ExternalDNS
// ----------------------------------------------------------------------------
module "dns" {
  source = "./modules/dns"

  dns_sa_email        = var.dns_sa_email
  jenkins_x_namespace = module.cluster.jenkins_x_namespace
  jx2                 = var.jx2
}

// ----------------------------------------------------------------------------
// Let's generate jx-requirements.yml 
// ----------------------------------------------------------------------------
locals {
  interpolated_content = templatefile("${path.module}/modules/jx-requirements.yml.tpl", {
    gcp_project                 = var.gcp_project
    zone                        = var.cluster_location
    cluster_name                = local.cluster_name
    git_owner_requirement_repos = var.git_owner_requirement_repos
    dev_env_approvers           = var.dev_env_approvers
    lets_encrypt_production     = var.lets_encrypt_production
    // Storage buckets
    log_storage_url        = var.log_storage_url
    report_storage_url     = var.report_storage_url
    repository_storage_url = var.repository_storage_url
    backup_bucket_url      = var.backup_bucket_url
    // Vault
    external_vault = local.external_vault
    vault_bucket   = var.vault_bucket_name
    vault_key      = var.vault_key
    vault_keyring  = var.vault_keyring
    vault_name     = var.vault_name
    vault_sa       = var.vault_sa
    vault_url      = var.vault_url
    // Velero
    enable_backup    = var.enable_backup
    velero_sa        = var.backup_velero_sa
    velero_namespace = var.backup_bucket_url != "" ? var.velero_namespace : ""
    velero_schedule  = var.velero_schedule
    velero_ttl       = var.velero_ttl
    // DNS
    domain_enabled = var.parent_domain != "" ? true : false
    parent_domain  = var.parent_domain
    tls_email      = var.tls_email

    version_stream_ref = var.version_stream_ref
    version_stream_url = var.version_stream_url
    webhook            = var.webhook
  })

  split_content   = split("\n", local.interpolated_content)
  compact_content = compact(local.split_content)
  content         = join("\n", local.compact_content)
}