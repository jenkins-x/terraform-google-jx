output "vault_sa" {
  value = "${google_service_account.vault_sa.account_id}"
}

output "vault_bucket_name" {
  value = "${google_storage_bucket.vault_bucket.name}"
}

output "vault_bucket_url" {
  value = "${google_storage_bucket.vault_bucket.url}"
}

