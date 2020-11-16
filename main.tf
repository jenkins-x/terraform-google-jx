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
provider "google" {
  project = var.gcp_project
  version = ">= 3.46.0"
}

provider "google-beta" {
  project = var.gcp_project
  version = ">= 3.46.0"
}

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

data "google_client_config" "default" {
}

provider "kubernetes" {
  version          = ">= 1.11.0"
  load_config_file = false

  host                   = "https://${module.cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
}

provider "helm" {
  version = "~>1.3.0"
  debug   = true

  kubernetes {
    host                   = "https://${module.cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(module.cluster.cluster_client_certificate)
    client_key             = base64decode(module.cluster.client_client_key)
    cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)

    load_config_file = false
  }
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
  cluster_name = var.cluster_name != "" ? var.cluster_name : random_pet.current.id
  # provide backwards compatibility with the deprecated zone variable
  location       = var.zone != "" ? var.zone : var.cluster_location
  external_vault = var.vault_url != "" ? true : false
}

// ----------------------------------------------------------------------------
// Enable all required GCloud APIs
//
// https://www.terraform.io/docs/providers/google/r/google_project_service.html
// ----------------------------------------------------------------------------
resource "google_project_service" "cloudresourcemanager_api" {
  provider           = google
  project            = var.gcp_project
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  provider           = google
  project            = var.gcp_project
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  provider           = google
  project            = var.gcp_project
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild_api" {
  provider           = google
  project            = var.gcp_project
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containerregistry_api" {
  provider           = google
  project            = var.gcp_project
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis_api" {
  provider           = google
  project            = var.gcp_project
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "serviceusage_api" {
  provider           = google
  project            = var.gcp_project
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_api" {
  provider           = google
  project            = var.gcp_project
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

// ----------------------------------------------------------------------------
// Create Kubernetes cluster
// ----------------------------------------------------------------------------
module "cluster" {
  source = "./modules/cluster"

  gcp_project         = var.gcp_project
  cluster_name        = local.cluster_name
  cluster_location    = local.location
  cluster_network     = var.cluster_network
  cluster_id          = random_id.random.hex
  bucket_location     = var.bucket_location
  jenkins_x_namespace = var.jenkins_x_namespace
  force_destroy       = var.force_destroy

  node_machine_type = var.node_machine_type
  node_disk_size    = var.node_disk_size
  node_disk_type    = var.node_disk_type
  node_preemptible  = var.node_preemptible
  min_node_count    = var.min_node_count
  max_node_count    = var.max_node_count
  release_channel   = var.release_channel
  resource_labels   = var.resource_labels

  create_ui_sa = var.create_ui_sa
  jx2          = var.jx2
  content      = local.content

  jx_git_url      = var.jx_git_url
  jx_bot_username = var.jx_bot_username
  jx_bot_token    = var.jx_bot_token
}

// ----------------------------------------------------------------------------
// Setup all required resources for using the  bank-vaults operator
// See https://github.com/banzaicloud/bank-vaults
// ----------------------------------------------------------------------------
module "vault" {
  count  = ! var.gsm ? 1 : 0
  source = "./modules/vault"

  gcp_project         = var.gcp_project
  cluster_name        = local.cluster_name
  cluster_id          = random_id.random.hex
  bucket_location     = var.bucket_location
  jenkins_x_namespace = module.cluster.jenkins_x_namespace
  force_destroy       = var.force_destroy
  external_vault      = local.external_vault
  jx2                 = var.jx2
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Google Secrets Manager
// See https://cloud.google.com/secret-manager
// ----------------------------------------------------------------------------
module "gsm" {
  count  = var.gsm && ! var.jx2 ? 1 : 0
  source = "./modules/gsm"

  gcp_project  = var.gcp_project
  cluster_name = local.cluster_name
  cluster_id   = random_id.random.hex
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Velero for cluster backups
// ----------------------------------------------------------------------------
module "backup" {
  source = "./modules/backup"

  enable_backup       = var.enable_backup
  gcp_project         = var.gcp_project
  cluster_name        = local.cluster_name
  cluster_id          = random_id.random.hex
  bucket_location     = var.bucket_location
  jenkins_x_namespace = module.cluster.jenkins_x_namespace
  force_destroy       = var.force_destroy
  jx2                 = var.jx2
}

// ----------------------------------------------------------------------------
// Setup ExternalDNS
// ----------------------------------------------------------------------------
module "dns" {
  source = "./modules/dns"

  gcp_project         = var.gcp_project
  cluster_name        = local.cluster_name
  parent_domain       = var.parent_domain
  jenkins_x_namespace = module.cluster.jenkins_x_namespace
  jx2                 = var.jx2
  subdomain           = var.subdomain
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
    log_storage_url        = module.cluster.log_storage_url
    report_storage_url     = module.cluster.report_storage_url
    repository_storage_url = module.cluster.repository_storage_url
    backup_bucket_url      = module.backup.backup_bucket_url
    // Vault
    external_vault = local.external_vault
    vault_bucket   = length(module.vault) > 0 ? module.vault[0].vault_bucket_name : ""
    vault_key      = length(module.vault) > 0 ? module.vault[0].vault_key : ""
    vault_keyring  = length(module.vault) > 0 ? module.vault[0].vault_keyring : ""
    vault_name     = length(module.vault) > 0 ? module.vault[0].vault_name : ""
    vault_sa       = length(module.vault) > 0 ? module.vault[0].vault_sa : ""
    vault_url      = var.vault_url
    // Velero
    enable_backup    = var.enable_backup
    velero_sa        = module.backup.velero_sa
    velero_namespace = module.backup.backup_bucket_url != "" ? var.velero_namespace : ""
    velero_schedule  = var.velero_schedule
    velero_ttl       = var.velero_ttl
    // DNS
    domain_enabled = var.parent_domain != "" ? true : false
    parent_domain  = var.parent_domain
    subdomain      = var.subdomain
    tls_email      = var.tls_email

    version_stream_ref = var.version_stream_ref
    version_stream_url = var.version_stream_url
    webhook            = var.webhook
  })

  split_content   = split("\n", local.interpolated_content)
  compact_content = compact(local.split_content)
  content         = join("\n", local.compact_content)
}
