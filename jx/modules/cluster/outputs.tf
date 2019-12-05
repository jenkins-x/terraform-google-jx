output "lts_bucket" {
  value = "${google_storage_bucket.lts_bucket.name}"
}

output "kaniko_sa" {
  value = "${google_service_account.kaniko_sa.account_id}"
}

output "jxboot_sa" {
  value = "${google_service_account.jxboot_sa.account_id}"
}
