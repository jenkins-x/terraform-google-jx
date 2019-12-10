output "lts_bucket_name" {
  value = "${google_storage_bucket.lts_bucket.name}"
}

output "lts_bucket_url" {
  value = "${google_storage_bucket.lts_bucket.url}"
}

output "kaniko_sa" {
  value = "${google_service_account.kaniko_sa.account_id}"
}
