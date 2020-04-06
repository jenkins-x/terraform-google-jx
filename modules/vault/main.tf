// ----------------------------------------------------------------------------
// Enable all GCloud APIs needed for Vault
//
// https://www.terraform.io/docs/providers/google/r/google_project_service.html
// ----------------------------------------------------------------------------
resource "google_project_service" "cloudkms_api" {
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
  provider    = google
  name        = "keyring-${var.cluster_name}-${var.cluster_id}"
  location    = "global"
  depends_on  = [google_project_service.cloudkms_api]
}

resource "google_kms_crypto_key" "vault_crypto_key" {
  provider         = google
  name             = "crypto-key-${var.cluster_name}-${var.cluster_id}"
  key_ring         = google_kms_key_ring.vault_keyring.self_link
  rotation_period  = "100000s"
  depends_on       = [google_project_service.cloudkms_api]
}

// ----------------------------------------------------------------------------
// Create bucket for Vault data
//
// https://www.terraform.io/docs/providers/google/r/storage_bucket.html
// ----------------------------------------------------------------------------
resource "google_storage_bucket" "vault_bucket" {
  provider      = google
  name          = "vault-${var.cluster_name}-${var.cluster_id}"
  location      = var.zone
  
  force_destroy = var.force_destroy
}

// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
resource "google_service_account" "vault_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-vt"
  display_name = substr("Vault service account for cluster ${var.cluster_name}", 0, 100)          
}

resource "google_project_iam_member" "vault_sa_storage_object_admin_binding" {
  provider = google
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "google_project_iam_member" "vault_sa_cloudkms_admin_binding" {
  provider = google
  role     = "roles/cloudkms.admin"
  member   = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "google_project_iam_member" "vault_sa_cloudkms_crypto_binding" {
  provider = google
  role     = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member   = "serviceAccount:${google_service_account.vault_sa.email}"
}

// ----------------------------------------------------------------------------
// Setup K8s Vault service accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account_iam.html#google_service_account_iam_member
// https://www.terraform.io/docs/providers/kubernetes/r/service_account.html
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "vault_auth_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.vault_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/vault-auth]"
}

resource "google_service_account_iam_member" "vault_operator_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.vault_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/${var.cluster_name}-vt]"
}

resource "kubernetes_service_account" "vault_sa" {
  automount_service_account_token = true
  metadata {
    name = "${var.cluster_name}-vt"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.vault_sa.email
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
