output "vault_name" {
  value = var.cluster_name
}

output "vault_sa" {
  description = "Id of Google Service Account for Vault"
  value       = google_service_account.vault_sa.account_id
}

output "vault_bucket_name" {
  description = "Bucket name for Vault data"
  value = google_storage_bucket.vault_bucket.name
}

output "vault_bucket_url" {
    value = google_storage_bucket.vault_bucket.url
}

output "vault_key" {
  description = "Vault KMS key to use"
  value = google_kms_crypto_key.vault_crypto_key.name
}

output "vault_keyring" {
   description = "Name of the KMS keyring for the project"
  value = google_kms_key_ring.vault_keyring.name
}
