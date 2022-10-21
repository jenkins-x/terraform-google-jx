// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
// argocd
resource "google_service_account" "argocd_sa" {
  provider     = google
  account_id   = "argocd-${var.cluster_name}"
  display_name = substr("ArgoCD service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "argocd_sa_secret_manager_admin_binding" {
  project  = var.gcp_project
  provider = google
  role     = "roles/secretmanager.admin"
  member   = "serviceAccount:${google_service_account.argocd_sa.email}"
}

resource "google_project_iam_member" "argocd_sa_container_developer_binding" {
  project  = var.gcp_project
  provider = google
  role     = "roles/container.developer"
  member   = "serviceAccount:${google_service_account.argocd_sa.email}"
}

resource "google_service_account_iam_member" "argocd_app_controller_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.argocd_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[argocd/argocd-application-controller]"
}

resource "google_service_account_iam_member" "argocd_repo_server_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.argocd_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[argocd/argocd-repo-server]"
}

resource "google_service_account_iam_member" "argocd_server_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.argocd_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[argocd/argocd-server]"
}
