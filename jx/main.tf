// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// Using pessemistic version locking for all versions 
// ----------------------------------------------------------------------------
terraform {
  required_version = "~> 0.12.0"
}

// ----------------------------------------------------------------------------
// Configure providers
// ----------------------------------------------------------------------------
provider "google" {
  version = "~> 3.10"
  project = var.gcp_project
  zone    = var.zone
}

provider "google-beta" {
  version = "~> 3.10"
  project = var.gcp_project
  zone    = var.zone
}

provider "random" {
  version = "~> 2.2"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "google_client_config" "default" {
}

provider "kubernetes" {
  version          = "~> 1.11"
  load_config_file = false

  host  = "https://${module.cluster.cluster_endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    module.cluster.cluster_ca_certificate,
  )
}

resource "random_id" "random" {
  byte_length = 6
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

// ----------------------------------------------------------------------------
// Create K8s cluster
// ----------------------------------------------------------------------------
module "cluster" {
  source = "./modules/cluster"

  gcp_project         = var.gcp_project
  zone                = var.zone
  cluster_name        = var.cluster_name
  cluster_id          = random_id.random.hex
  jenkins_x_namespace = var.jenkins_x_namespace

  node_machine_type = var.node_machine_type
}

// ----------------------------------------------------------------------------
// Setup all required resources for using the  bank-vaults operator
// See https://github.com/banzaicloud/bank-vaults
// ----------------------------------------------------------------------------
module "vault" {
  source = "./modules/vault"

  gcp_project         = var.gcp_project
  zone                = var.zone
  cluster_name        = var.cluster_name
  jenkins_x_namespace = var.jenkins_x_namespace
  cluster_id          = random_id.random.hex
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Velero for cluster backups
// ----------------------------------------------------------------------------
module "backup" {
  source = "./modules/backup"

  gcp_project  = var.gcp_project
  zone         = var.zone
  cluster_name = var.cluster_name
  cluster_id       = random_id.random.hex
}

// ----------------------------------------------------------------------------
// Setup ExternalDNS
// ----------------------------------------------------------------------------
module "dns" {
  source = "./modules/dns"

  gcp_project   = var.gcp_project
  cluster_name  = var.cluster_name
  dns_enabled   = var.parent_domain != "" ? true : false
  parent_domain = var.parent_domain
}
