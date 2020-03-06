output "backup_bucket_name" {
  value = google_storage_bucket.backup_bucket.name
}

output "backup_bucket_url" {
  value = google_storage_bucket.backup_bucket.url
}

output "velero_sa" {
  value = google_service_account.velero_sa.account_id
}
