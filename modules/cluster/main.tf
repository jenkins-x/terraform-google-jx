resource "google_container_cluster" "jx_cluster" {
  provider                = "google-beta"
  name                    = var.cluster_name
  description             = "jx k8s cluster"
  location                = var.zone
  enable_kubernetes_alpha = var.enable_kubernetes_alpha
  enable_legacy_abac      = var.enable_legacy_abac
  initial_node_count      = var.min_node_counts[var.cluster_size]
  logging_service         = var.logging_service
  monitoring_service      = var.monitoring_service

  node_config {
    preemptible  = var.node_preemptible
    machine_type = var.node_machine_types[var.cluster_size]
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
  resource_labels = {
    type = var.test_cluster_label
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  //lifecycle {
  //  prevent_destroy = true
  //}
}

resource "google_storage_bucket" "lts_bucket" {
  provider      = "google"
  name          = "${var.project_id}-lts"
  location      = "US"
  force_destroy = "true"
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

resource "google_service_account_iam_binding" "kaniko_sa_workload_binding" {
  provider           = "google"
  service_account_id = "${google_service_account.kaniko_sa.name}"
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.service_name}/${var.cluster_name}-${var.kaniko_sa_suffix}]",
  ]

  depends_on = [
    "google_container_cluster.jx_cluster"
  ]
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

resource "google_service_account_iam_binding" "jxboot_sa_workload_binding" {
  provider           = "google"
  service_account_id = "${google_service_account.jxboot_sa.name}"
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.service_name}/${var.cluster_name}-${var.jxboot_sa_suffix}]",
  ]

  depends_on = [
    "google_container_cluster.jx_cluster"
  ]
}

resource "google_service_account" "storage_sa" {
  provider     = "google"
  account_id   = "${var.cluster_name}-${var.storage_sa_suffix}"
  display_name = "Storage service account for ${var.cluster_name}"
}
