output "backup_bucket_name" {
  value = "${google_storage_bucket.backup_bucket.name}"
}

output "backup_bucket_url" {
  value = "${google_storage_bucket.backup_bucket.url}"
}

