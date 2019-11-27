output "vault_bucket" {
  value = "${google_storage_bucket.vault_bucket.name}"
}

output "vault_sa" {
  value = "${google_service_account.vault_sa.account_id}"
}
