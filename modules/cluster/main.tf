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
  network = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.vpc_subnet.id
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.16.1.0/28"
    master_global_access_config {
      enabled = true
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }

  ip_allocation_policy {
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    istio_config {
      disabled = false
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
      minimum       = 1
      maximum       = 2
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

// ----------------------------------------------------------------------------
// Add main Jenkins X Kubernetes namespace
// 
// https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "jenkins_x_namespace" {
  count = var.jx2 ? 1 : 0
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

// ----------------------------------------------------------------------------
// Add the Terraform generated jx-requirements.yml to a configmap so it can be
// sync'd with the Git repository
//
// https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
// ----------------------------------------------------------------------------
resource "kubernetes_config_map" "jenkins_x_requirements" {
  count = var.jx2 ? 0 : 1
  metadata {
    name      = "terraform-jx-requirements"
    namespace = "default"
  }
  data = {
    "jx-requirements.yml" = var.content
  }

  lifecycle {
    ignore_changes = [
      metadata,
      data
    ]
  }
  depends_on = [
    google_container_cluster.jx_cluster
  ]
}

resource "helm_release" "jx-git-operator" {
  count = var.jx2 ? 0 : 1

  provider         = helm
  name             = "jx-git-operator"
  chart            = "jx-git-operator"
  namespace        = "jx-git-operator"
  repository       = "https://storage.googleapis.com/jenkinsxio/charts"
  create_namespace = true

  set {
    name  = "bootServiceAccount.enabled"
    value = true
  }
  set {
    name  = "bootServiceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = "${var.cluster_name}-boot@${var.gcp_project}.iam.gserviceaccount.com"
  }
  set {
    name  = "env.NO_RESOURCE_APPLY"
    value = true
  }
  set {
    name  = "url"
    value = var.jx_git_url
  }
  set {
    name  = "username"
    value = var.jx_bot_username
  }
  set {
    name  = "password"
    value = var.jx_bot_token
  }

  lifecycle {
    ignore_changes = all
  }
  depends_on = [
    google_container_cluster.jx_cluster
  ]
}
