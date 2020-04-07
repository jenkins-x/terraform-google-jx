// ----------------------------------------------------------------------------
// Create bucket for storing Velero backups 
//
// https://github.com/vmware-tanzu/velero
// https://www.terraform.io/docs/providers/google/r/storage_bucket.html
// ----------------------------------------------------------------------------
resource "google_storage_bucket" "backup_bucket" {
  provider      = google
  name          = "backup-${var.cluster_name}-${var.cluster_id}"

  force_destroy = var.force_destroy
}

// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
resource "google_service_account" "velero_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-vo"
  display_name = substr("Velero service account for cluster ${var.cluster_name}", 0, 100)          
}

resource "google_project_iam_member" "velero_sa_storage_admin_binding" {
  provider = google
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.velero_sa.email}"
}

resource "google_project_iam_member" "velero_sa_storage_object_admin_binding" {
  provider = google
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.velero_sa.email}"
}

resource "google_project_iam_member" "velero_sa_storage_object_creator_binding" {
  provider = google
  role     = "roles/storage.objectCreator"
  member   = "serviceAccount:${google_service_account.velero_sa.email}"
}

resource "google_service_account_iam_member" "velero_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.velero_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.velero_namespace}/velero-server]"
}

// ----------------------------------------------------------------------------
// Setup Kubernetes Velero namespace and service account
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "velero_namespace" {
  metadata {
    name = var.velero_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_service_account" "verlero_sa" {
  automount_service_account_token = true
  metadata {
    name = "velero-server"
    namespace = var.velero_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.velero_sa.email
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }

  depends_on = [
    kubernetes_namespace.velero_namespace
  ]
}
