output "vault_name" {
  value = var.cluster_name
}

output "vault_sa" {
  description = "Vault service account name"
  value       = local.sa_name
}

output "vault_sa_email" {
  description = "Vault service account email"
  value       = local.vault_sa_email
}

output "vault_bucket_name" {
  description = "Bucket name for Vault data"
  value       = length(google_storage_bucket.vault_bucket) > 0 ? google_storage_bucket.vault_bucket[0].name : ""
}

output "vault_bucket_url" {
  description = "Bucket URL for Vault data"
  value       = length(google_storage_bucket.vault_bucket) > 0 ? google_storage_bucket.vault_bucket[0].url : ""
}

output "vault_key" {
  description = "Vault KMS key to use"
  value       = length(google_kms_crypto_key.vault_crypto_key) > 0 ? google_kms_crypto_key.vault_crypto_key[0].name : ""
}

output "vault_keyring" {
  description = "Name of the KMS keyring for the project"
  value       = length(google_kms_key_ring.vault_keyring) > 0 ? google_kms_key_ring.vault_keyring[0].name : ""
}
