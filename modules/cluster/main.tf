// ----------------------------------------------------------------------------
// Create and configure the Kubernetes cluster
//
// https://www.terraform.io/docs/providers/google/r/container_cluster.html
// ----------------------------------------------------------------------------
locals {
  cluster_oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/service.management",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
  master_authorized_networks_config = length(var.master_authorized_networks) == 0 ? [] : [{
    cidr_blocks : var.master_authorized_networks
  }]
  enable_private_cluster_config = (var.enable_private_nodes || var.enable_private_endpoint) ? true : false
  enable_vpc_native             = (var.ip_range_pods != "" || var.ip_range_services != "") ? true : false
  max_pods_per_node             = local.enable_vpc_native ? var.max_pods_per_node : null
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

resource "google_container_cluster" "jx_cluster" {
  name                      = var.cluster_name
  description               = "jenkins-x cluster"
  location                  = var.cluster_location
  network                   = var.cluster_network
  subnetwork                = var.cluster_subnetwork
  enable_kubernetes_alpha   = var.enable_kubernetes_alpha
  enable_legacy_abac        = var.enable_legacy_abac
  enable_shielded_nodes     = var.enable_shielded_nodes
  remove_default_node_pool  = true
  initial_node_count        = var.min_node_count
  logging_service           = var.logging_service
  monitoring_service        = var.monitoring_service
  default_max_pods_per_node = local.max_pods_per_node

  dynamic "private_cluster_config" {
    for_each = local.enable_private_cluster_config ? [{
      enable_private_nodes    = var.enable_private_nodes
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }] : []

    content {
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = local.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  dynamic "ip_allocation_policy" {
    for_each = local.enable_vpc_native ? [{
      ip_range_pods     = var.ip_range_pods
      ip_range_services = var.ip_range_services
    }] : []

    content {
      cluster_ipv4_cidr_block  = ip_allocation_policy.value.ip_range_pods
      services_ipv4_cidr_block = ip_allocation_policy.value.ip_range_services
    }
  }

  // should disable master auth
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project}.svc.id.goog"
  }

  resource_labels = var.resource_labels

}

resource "google_container_node_pool" "primary" {
  name               = "${var.cluster_name}-primary"
  location           = var.cluster_location
  cluster            = google_container_cluster.jx_cluster.name
  initial_node_count = var.min_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    preemptible  = var.node_preemptible
    spot         = var.node_spot
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = var.node_disk_type

    oauth_scopes = local.cluster_oauth_scopes

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

