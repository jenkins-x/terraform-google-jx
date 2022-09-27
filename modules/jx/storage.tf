// ----------------------------------------------------------------------------
// Create storage buckets for build related artifacts - logs, reports and 
// build artifacts 
//
// https://www.terraform.io/docs/providers/google/r/storage_bucket.html
// ----------------------------------------------------------------------------
resource "google_storage_bucket" "log_bucket" {
  count = var.enable_log_storage ? 1 : 0

  provider = google
  name     = "logs-${var.cluster_name}-${var.cluster_id}"
  location = var.bucket_location

  force_destroy = var.force_destroy
}

resource "google_storage_bucket" "report_bucket" {
  count = var.enable_report_storage ? 1 : 0

  provider = google
  name     = "reports-${var.cluster_name}-${var.cluster_id}"
  location = var.bucket_location

  force_destroy = var.force_destroy
}

resource "google_storage_bucket" "repository_bucket" {
  count = var.enable_repository_storage ? 1 : 0

  provider = google
  name     = "repository-${var.cluster_name}-${var.cluster_id}"
  location = var.bucket_location

  force_destroy = var.force_destroy
}
