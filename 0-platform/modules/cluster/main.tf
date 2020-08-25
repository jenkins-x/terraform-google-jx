// ----------------------------------------------------------------------------
// Create and configure the Kubernetes cluster
//
// https://www.terraform.io/docs/providers/google/r/container_cluster.html
// ----------------------------------------------------------------------------
resource "google_container_cluster" "jx_cluster" {
  provider                = google-beta
  name                    = var.cluster_name
  description             = "jenkins-x cluster"
  location                = var.cluster_location
  enable_kubernetes_alpha = var.enable_kubernetes_alpha
  enable_legacy_abac      = var.enable_legacy_abac
  initial_node_count      = var.min_node_count
  logging_service         = var.logging_service
  monitoring_service      = var.monitoring_service
  network                 = var.cluster_network
  subnetwork              = var.cluster_subnetwork

  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy.enabled ? [var.ip_allocation_policy] : []
    iterator = it
    content {
      cluster_secondary_range_name  = lookup(it, "cluster_secondary_range_name", null)
      services_secondary_range_name = lookup(it, "services_secondary_range_name", null)
      cluster_ipv4_cidr_block       = lookup(it, "cluster_ipv4_cidr_block", null)
      services_ipv4_cidr_block      = lookup(it, "services_ipv4_cidr_block", null)
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.cluster_private.enabled ? [{}] : []
    content {
      dynamic "cidr_blocks" {
        for_each = contains(keys(var.cluster_private), "master_authorized_cidr") ? [var.cluster_private.master_authorized_cidr] : []
        iterator = it
        content {
          cidr_block = it.value
        }
      }
    }
  }

  private_cluster_config {
    enable_private_nodes    = var.cluster_private.enabled
    enable_private_endpoint = var.cluster_private.enabled
    master_ipv4_cidr_block  = lookup(var.cluster_private, "master_ipv4_cidr_block", null)
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "09:00"
    }
  }

  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    identity_namespace = "${var.gcp_project}.svc.id.goog"
  }

  resource_labels = var.resource_labels

  cluster_autoscaling {
    enabled = true

    resource_limits {
      resource_type = "cpu"
      minimum       = ceil(var.min_node_count * var.machine_types_cpu[var.node_machine_type])
      maximum       = ceil(var.max_node_count * var.machine_types_cpu[var.node_machine_type])
    }

    resource_limits {
      resource_type = "memory"
      minimum       = ceil(var.min_node_count * var.machine_types_memory[var.node_machine_type])
      maximum       = ceil(var.max_node_count * var.machine_types_memory[var.node_machine_type])
    }
  }

  node_config {
    preemptible  = var.node_preemptible
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = var.node_disk_type

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
}
