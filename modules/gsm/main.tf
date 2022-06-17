locals {
  sa_name      = "${var.cluster_name}-sm"
  gsm_sa_name  = length(google_service_account.gsm_sa) > 0 ? google_service_account.gsm_sa.name : ""
  gsm_sa_email = length(google_service_account.gsm_sa) > 0 ? google_service_account.gsm_sa.email : ""
}

// ----------------------------------------------------------------------------
// Enable all GCloud APIs needed for GSM
//
// https://www.terraform.io/docs/providers/google/r/google_project_service.html
// ----------------------------------------------------------------------------
resource "google_project_service" "secretmanager_api" {
  provider           = google
  project            = var.gcp_project
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
resource "google_service_account" "gsm_sa" {
  provider     = google
  account_id   = local.sa_name
  display_name = substr("GSM service account for cluster ${var.cluster_name}", 0, 100)
}

// ----------------------------------------------------------------------------
// Setup Kubernetes GSM service accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account_iam.html#google_service_account_iam_member
// https://www.terraform.io/docs/providers/kubernetes/r/service_account.html
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "gsm_workload_identity_user" {
  provider           = google
  service_account_id = local.gsm_sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[secret-infra/kubernetes-external-secrets]"
}

resource "google_project_iam_member" "gsm_sa_secret_accessor_binding" {
  provider = google
  project  = var.gcp_project
  role     = "roles/secretmanager.secretAccessor"
  member   = "serviceAccount:${local.gsm_sa_email}"
}
