locals {
  sa_name        = "${var.cluster_name}-vt"
  vault_sa_name  = length(google_service_account.vault_sa) > 0 ? google_service_account.vault_sa[0].name : ""
  vault_sa_email = length(google_service_account.vault_sa) > 0 ? google_service_account.vault_sa[0].email : ""
}

// ----------------------------------------------------------------------------
// Enable all GCloud APIs needed for Vault
//
// https://www.terraform.io/docs/providers/google/r/google_project_service.html
// ----------------------------------------------------------------------------
resource "google_project_service" "cloudkms_api" {
  count = var.external_vault ? 0 : 1

  provider           = google
  project            = var.gcp_project
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

// ----------------------------------------------------------------------------
// Setup the Cloud Key Management Service (KMS)
//
// https://www.terraform.io/docs/providers/google/d/google_kms_key_ring.html
// ---------------------------------------------------------------------------
resource "google_kms_key_ring" "vault_keyring" {
  count = var.external_vault ? 0 : 1

  provider   = google
  name       = "keyring-${var.cluster_name}-${var.cluster_id}"
  location   = "global"
  depends_on = [google_project_service.cloudkms_api]
}

resource "google_kms_crypto_key" "vault_crypto_key" {
  count = var.external_vault ? 0 : 1

  provider        = google
  name            = "crypto-key-${var.cluster_name}-${var.cluster_id}"
  key_ring        = google_kms_key_ring.vault_keyring[0].id
  rotation_period = "100000s"
  depends_on      = [google_project_service.cloudkms_api]
}

// ----------------------------------------------------------------------------
// Create bucket for Vault data
//
// https://www.terraform.io/docs/providers/google/r/storage_bucket.html
// ----------------------------------------------------------------------------
resource "google_storage_bucket" "vault_bucket" {
  count = var.external_vault ? 0 : 1

  provider      = google
  name          = "vault-${var.cluster_name}-${var.cluster_id}"
  location      = var.bucket_location
  force_destroy = var.force_destroy
}

// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
resource "google_service_account" "vault_sa" {
  count        = var.external_vault && !var.jx2 ? 0 : 1
  provider     = google
  account_id   = local.sa_name
  display_name = substr("Vault service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "vault_sa_storage_object_admin_binding" {
  count    = var.external_vault ? 0 : 1
  project  = var.gcp_project
  provider = google
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${local.vault_sa_email}"
}

resource "google_project_iam_member" "vault_sa_cloudkms_admin_binding" {
  count    = var.external_vault ? 0 : 1
  project  = var.gcp_project
  provider = google
  role     = "roles/cloudkms.admin"
  member   = "serviceAccount:${local.vault_sa_email}"
}

resource "google_project_iam_member" "vault_sa_cloudkms_crypto_binding" {
  count    = var.external_vault ? 0 : 1
  project  = var.gcp_project
  provider = google
  role     = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member   = "serviceAccount:${local.vault_sa_email}"
}

// ----------------------------------------------------------------------------
// Setup Kubernetes Vault service accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account_iam.html#google_service_account_iam_member
// https://www.terraform.io/docs/providers/kubernetes/r/service_account.html
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "vault_auth_workload_identity_user" {
  count = var.external_vault ? 0 : 1

  provider           = google
  service_account_id = local.vault_sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/vault-auth]"
}

resource "google_service_account_iam_member" "vault_operator_workload_identity_user" {
  count = var.external_vault ? 0 : 1

  provider           = google
  service_account_id = local.vault_sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/${var.cluster_name}-vt]"
}

resource "kubernetes_service_account" "vault_sa" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = local.sa_name
    namespace = var.jenkins_x_namespace
    annotations = var.external_vault ? {} : {
      "iam.gke.io/gcp-service-account" = local.vault_sa_email
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }
}
