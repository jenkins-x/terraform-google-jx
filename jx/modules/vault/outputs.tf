output "vault_sa" {
  value = "${google_service_account.vault_sa.account_id}"
}

output "vault_bucket_name" {
  value = "${google_storage_bucket.vault_bucket.name}"
}

output "vault_bucket_url" {
  value = "${google_storage_bucket.vault_bucket.url}"
}

output "vault_key" {
  value = "${google_kms_crypto_key.vault_crypto_key.name}"
}

output "vault_keyring" {
  value = "${google_kms_key_ring.vault_keyring.name}"
}

output "vault_name" {
  value = "${var.cluster_name}"
}
