// ----------------------------------------------------------------------------
// Create and configure the Kubernetes cluster
//
// https://www.terraform.io/docs/providers/google/r/container_cluster.html
// ----------------------------------------------------------------------------
resource "google_container_cluster" "jx_cluster" {
  provider                 = google-beta
  name                     = var.cluster_name
  description              = "jenkins-x cluster"
  location                 = var.cluster_location
  enable_kubernetes_alpha  = var.enable_kubernetes_alpha
  enable_legacy_abac       = var.enable_legacy_abac
  logging_service          = var.logging_service
  monitoring_service       = var.monitoring_service

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    identity_namespace = "${var.gcp_project}.svc.id.goog"
  }

  resource_labels = var.resource_labels
}

// ----------------------------------------------------------------------------
// Create node pool independently of the cluster.
// This is the recommended way for running a GKE cluster via Terraform
//
// https://www.terraform.io/docs/providers/google/r/container_node_pool.html
// ----------------------------------------------------------------------------
resource "google_container_node_pool" "jx_node_pool" {
  provider           = google-beta
  name               = "autoscale-pool"
  location           = var.cluster_location
  cluster            = google_container_cluster.jx_cluster.name
  initial_node_count = var.min_node_count

  node_config {
    preemptible  = var.node_preemptible
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }
}

// ----------------------------------------------------------------------------
// Add main Jenkins X Kubernetes namespace
// 
// https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "jenkins_x_namespace" {
  metadata {
    name = var.jenkins_x_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }

  depends_on = [
    google_container_cluster.jx_cluster,
    google_container_node_pool.jx_node_pool
  ]
}
