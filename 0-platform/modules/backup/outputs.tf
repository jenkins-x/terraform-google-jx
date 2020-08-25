output "backup_bucket_name" {
  value = length(google_storage_bucket.backup_bucket) > 0 ? google_storage_bucket.backup_bucket[0].name : ""
}

output "backup_bucket_url" {
  value = length(google_storage_bucket.backup_bucket) > 0 ? google_storage_bucket.backup_bucket[0].url : ""
}

output "velero_sa" {
  value = length(google_service_account.velero_sa) > 0 ? google_service_account.velero_sa[0].account_id : ""
}

output "velero_sa_email" {
  value = length(google_service_account.velero_sa) > 0 ? google_service_account.velero_sa[0].email : ""
}