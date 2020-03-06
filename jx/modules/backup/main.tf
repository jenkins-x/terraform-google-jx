// ----------------------------------------------------------------------------
// Create bucket for storing Velero backups 
//
// https://github.com/vmware-tanzu/velero
// https://www.terraform.io/docs/providers/google/r/storage_bucket.html
// ----------------------------------------------------------------------------
resource "google_storage_bucket" "backup_bucket" {
  provider      = google
  name          = "backup-${var.cluster_name}-${var.cluster_id}"
  location      = "US"
  force_destroy = true
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
  display_name = "Velero service account for ${var.cluster_name}"
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
