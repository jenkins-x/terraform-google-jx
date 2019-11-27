resource "google_storage_bucket" "backup_bucket" {
  provider      = "google"
  name          = "${var.project_id}-backup"
  location      = "US"
  force_destroy = "true"
}

resource "google_service_account" "velero_sa" {
  provider     = "google"
  account_id   = "${var.cluster_name}-${var.velero_sa_suffix}"
  display_name = "Velero service account for ${var.cluster_name}"
}

resource "google_project_iam_member" "velero_sa_storage_admin_binding" {
  provider = "google"
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.velero_sa.email}"
}

resource "google_project_iam_member" "velero_sa_storage_object_admin_binding" {
  provider = "google"
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.velero_sa.email}"
}

resource "google_project_iam_member" "velero_sa_storage_object_creator_binding" {
  provider = "google"
  role     = "roles/storage.objectCreator"
  member   = "serviceAccount:${google_service_account.velero_sa.email}"
}
