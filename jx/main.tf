terraform {
  required_version = ">= 0.12.0"
}

provider "google" {
  project = var.gcp_project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.gcp_project
  region  = var.region
  zone    = var.zone
}

resource "google_project_service" "cloudresourcemanager_api" {
  provider           = "google"
  project            = var.gcp_project
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  provider           = "google"
  project            = var.gcp_project
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  provider           = "google"
  project            = var.gcp_project
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild_api" {
  provider           = "google"
  project            = var.gcp_project
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containerregistry_api" {
  provider           = "google"
  project            = var.gcp_project
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis_api" {
  provider           = "google"
  project            = var.gcp_project
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

module "cluster" {
  source = "./modules/cluster"

  gcp_project = var.gcp_project
  region = var.region
  zone = var.zone
  cluster_name = var.cluster_name
  parent_domain = var.parent_domain

  min_node_count = var.min_node_count
  max_node_count = var.max_node_count
  node_machine_type = var.node_machine_type
}

module "vault" {
  source = "./modules/vault"

  gcp_project = var.gcp_project
  region = var.region
  zone = var.zone
  cluster_name = var.cluster_name
}

module "backup" {
  source = "./modules/backup"

  gcp_project = var.gcp_project
  region = var.region
  zone = var.zone
  cluster_name = var.cluster_name
}

module "dns" {
  source = "./modules/dns"

  gcp_project = var.gcp_project
  region = var.region
  zone = var.zone
  cluster_name = var.cluster_name
}
