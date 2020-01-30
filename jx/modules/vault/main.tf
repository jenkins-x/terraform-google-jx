resource "google_project_service" "cloudkms_api" {
  provider           = "google"
  project            = var.gcp_project
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_kms_key_ring" "vault_keyring" {
  provider = "google"
  name     = "${var.cluster_name}-keyring"
  location = "global"
  depends_on = [google_project_service.cloudkms_api]
}

resource "google_kms_crypto_key" "vault_crypto_key" {
  provider        = "google"
  name            = "${var.cluster_name}-crypto-key"
  key_ring        = "${google_kms_key_ring.vault_keyring.self_link}"
  rotation_period = "100000s"
  depends_on = [google_project_service.cloudkms_api]

  //lifecycle {
  //  prevent_destroy = true
  //}
}

resource "google_storage_bucket" "vault_bucket" {
  provider      = "google"
  name          = "${var.gcp_project}-${random_id.rnd.hex}-vault"
  location      = "US"
  force_destroy = "true"
}

resource "google_service_account" "vault_sa" {
  provider     = "google"
  account_id   = "${var.cluster_name}-${var.vault_sa_suffix}"
  display_name = "Vault service account for ${var.cluster_name}"
}

resource "google_project_iam_member" "vault_sa_storage_object_admin_binding" {
  provider = "google"
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "google_project_iam_member" "vault_sa_cloudkms_admin_binding" {
  provider = "google"
  role     = "roles/cloudkms.admin"
  member   = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "google_project_iam_member" "vault_sa_cloudkms_crypto_binding" {
  provider = "google"
  role     = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member   = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "random_id" "rnd" {
  byte_length = 6
}
