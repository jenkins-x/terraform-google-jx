resource "google_container_cluster" "jx_cluster" {
  provider                 = "google-beta"
  name                     = var.cluster_name
  description              = "jx k8s cluster"
  location                 = var.zone
  enable_kubernetes_alpha  = var.enable_kubernetes_alpha
  enable_legacy_abac       = var.enable_legacy_abac
  initial_node_count       = var.min_node_count
  logging_service          = var.logging_service
  monitoring_service       = var.monitoring_service
  remove_default_node_pool = "true"

  resource_labels = {
    type = var.test_cluster_label
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  //lifecycle {
  //  prevent_destroy = true
  //}
}

resource "google_container_node_pool" "jx_node_pool" {
  provider                = "google-beta"
  name                    = "autoscale-pool"
  location                = var.zone
  cluster                 = google_container_cluster.jx_cluster.name
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
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  depends_on = [
    google_container_cluster.jx_cluster
  ]
}

resource "google_storage_bucket" "lts_bucket" {
  provider      = "google"
  name          = "${var.gcp_project}-${random_id.rnd.hex}-lts"
  location      = "US"
  force_destroy = "true"
}

resource "google_storage_bucket" "repository_bucket" {
  provider      = "google"
  name          = "${var.gcp_project}-${random_id.rnd.hex}-repository"
  location      = "US"
  force_destroy = "true"
  count         = "${var.repository_enabled}"
}

resource "google_service_account" "kaniko_sa" {
  provider     = "google"
  account_id   = "${var.cluster_name}-${var.kaniko_sa_suffix}"
  display_name = "Kaniko service account for ${var.cluster_name}"
}

resource "google_project_iam_member" "kaniko_sa_storage_admin_binding" {
  provider = "google"
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.kaniko_sa.email}"
}

resource "google_project_iam_member" "kaniko_sa_storage_object_admin_binding" {
  provider = "google"
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.kaniko_sa.email}"
}

resource "google_project_iam_member" "kaniko_sa_storage_object_creator_binding" {
  provider = "google"
  role     = "roles/storage.objectCreator"
  member   = "serviceAccount:${google_service_account.kaniko_sa.email}"
}

resource "google_service_account" "jxboot_sa" {
  provider     = "google"
  account_id   = "${var.cluster_name}-${var.jxboot_sa_suffix}"
  display_name = "jx-boot service account for ${var.cluster_name}"
}

resource "google_project_iam_member" "jxboot_sa_dns_admin_binding" {
  provider = "google"
  role     = "roles/dns.admin"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

resource "google_project_iam_member" "jxboot_sa_project_viewer_binding" {
  provider = "google"
  role     = "roles/viewer"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

resource "google_project_iam_member" "jxboot_sa_service_account_key_binding" {
  provider = "google"
  role     = "roles/iam.serviceAccountKeyAdmin"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

resource "google_project_iam_member" "jxboot_sa_storage_admin_binding" {
  provider = "google"
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

resource "google_service_account" "storage_sa" {
  provider     = "google"
  account_id   = "${var.cluster_name}-${var.storage_sa_suffix}"
  display_name = "Storage service account for ${var.cluster_name}"
}

resource "random_id" "rnd" {
  byte_length = 6
}
