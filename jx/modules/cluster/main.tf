// ----------------------------------------------------------------------------
// Create and configure the K8s cluster
//
// https://www.terraform.io/docs/providers/google/r/container_cluster.html
// ----------------------------------------------------------------------------
resource "google_container_cluster" "jx_cluster" {
  provider                 = google-beta
  name                     = var.cluster_name
  description              = "jenkins-x k8s cluster"
  location                 = var.zone
  enable_kubernetes_alpha  = var.enable_kubernetes_alpha
  enable_legacy_abac       = var.enable_legacy_abac
  logging_service          = var.logging_service
  monitoring_service       = var.monitoring_service

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  workload_identity_config {
    identity_namespace = "${var.gcp_project}.svc.id.goog"
  }

  node_pool {
    name                    = "default-pool"
    node_count              = var.min_node_count
  
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
      auto_upgrade = "false"
    }
  }
}

// ----------------------------------------------------------------------------
// Add main Jenkins X K8s namespace
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
    google_container_cluster.jx_cluster
  ]
}
