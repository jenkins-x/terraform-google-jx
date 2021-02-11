// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// Using pessimistic version locking for all versions
// ----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.0, < 0.15"
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

provider "external" {
  version = ">= 2.0.0"
}

provider "template" {
  version = ">= 2.1.0"
}

data "google_client_config" "default" {
}

provider "kubernetes" {
  version = ">= 1.13.0"

  host                   = "https://${module.cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
  proxy_url              = try("http://localhost:${data.external.bastion[0].result.port}", null)
}

provider "helm" {
  version = "~>2.0.1"
  debug   = true

  kubernetes {
    host                   = "https://${module.cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(module.cluster.cluster_client_certificate)
    client_key             = base64decode(module.cluster.client_client_key)
    cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)

    proxy_url = try("http://localhost:${data.external.bastion[0].result.port}", null)
  }
}

data "external" "bastion" {
  count   = var.private_cluster ? 1 : 0
  program = ["python3", "${path.module}/scripts/create_bastion_proxy.py"]
  query = {
    project  = var.gcp_project
    zone     = module.network[0].bastion_zone
    instance = module.network[0].bastion_name
    link     = module.network[0].bastion_link
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
// Create network
// ----------------------------------------------------------------------------

module "network" {
  source           = "./modules/network"
  count            = var.private_cluster ? 1 : 0
  cluster_name     = var.cluster_name
  network          = var.cluster_network
  gcp_project      = var.gcp_project
  cluster_location = var.cluster_location
}

// ----------------------------------------------------------------------------
// Create Kubernetes cluster
// ----------------------------------------------------------------------------
module "cluster" {
  source = "./modules/cluster"

  gcp_project         = var.gcp_project
  cluster_name        = local.cluster_name
  cluster_location    = local.location
  cluster_network     = try(module.network[0].network, var.cluster_network)
  cluster_subnetwork  = try(module.network[0].subnetwork, null)
  cluster_id          = random_id.random.hex
  bucket_location     = var.bucket_location
  jenkins_x_namespace = var.jenkins_x_namespace
  force_destroy       = var.force_destroy

  private_cluster = var.private_cluster
  svc_range_name  = try(module.network[0].svc_range_name, null)
  pod_range_name  = try(module.network[0].pod_range_name, null)
  master_range    = try(module.network[0].master_range, null)

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
  count  = !var.gsm ? 1 : 0
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
  count  = var.gsm && !var.jx2 ? 1 : 0
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
// TODO: remove parent_domain & parent_domain_gcp_project when their deprecations are complete
// ----------------------------------------------------------------------------
module "dns" {
  source = "./modules/dns"

  gcp_project                     = var.gcp_project
  cluster_name                    = local.cluster_name
  apex_domain                     = var.apex_domain != "" ? var.apex_domain : var.parent_domain
  jenkins_x_namespace             = module.cluster.jenkins_x_namespace
  jx2                             = var.jx2
  subdomain                       = var.subdomain
  apex_domain_gcp_project         = var.apex_domain_gcp_project != "" ? var.apex_domain_gcp_project : (var.parent_domain_gcp_project != "" ? var.parent_domain_gcp_project : var.gcp_project)
  apex_domain_integration_enabled = var.apex_domain_integration_enabled

  depends_on = [
    module.cluster
  ]
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
    // TODO: remove parent_domain when its deprecations is complete: domain_enabled = var.apex_domain != "" ? true : false
    domain_enabled = var.apex_domain != "" ? true : (var.parent_domain != "" ? true : false)
    // TODO: replace with the following when parent_domain deprecations is complete: apex_domain  = var.apex_domain
    apex_domain = var.apex_domain != "" ? var.apex_domain : var.parent_domain
    subdomain   = var.subdomain
    tls_email   = var.tls_email

    version_stream_ref = var.version_stream_ref
    version_stream_url = var.version_stream_url
    webhook            = var.webhook
  })

  split_content   = split("\n", local.interpolated_content)
  compact_content = compact(local.split_content)
  content         = join("\n", local.compact_content)
}
