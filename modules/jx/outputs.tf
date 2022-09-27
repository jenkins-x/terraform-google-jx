
output "log_storage_url" {
  value = length(google_storage_bucket.log_bucket) > 0 ? google_storage_bucket.log_bucket[0].url : ""
}

output "report_storage_url" {
  value = length(google_storage_bucket.report_bucket) > 0 ? google_storage_bucket.report_bucket[0].url : ""
}

output "repository_storage_url" {
  value = length(google_storage_bucket.repository_bucket) > 0 ? google_storage_bucket.repository_bucket[0].url : ""
}

output "jenkins_x_namespace" {
  value = var.jenkins_x_namespace
}

output "tekton_sa_email" {
  value = google_service_account.tekton_sa.email
}

output "tekton_sa_name" {
  value = google_service_account.tekton_sa.name
}
