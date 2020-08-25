output "cluster_name" {
  value = google_container_cluster.jx_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.jx_cluster.location
}

output "cluster_endpoint" {
  value = google_container_cluster.jx_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = length(google_container_cluster.jx_cluster.master_auth) > 0 ? google_container_cluster.jx_cluster.master_auth[0].cluster_ca_certificate : ""
}

output "log_storage_url" {
  value = length(google_storage_bucket.log_bucket) > 0 ? google_storage_bucket.log_bucket[0].url : ""
}

output "report_storage_url" {
  value = length(google_storage_bucket.report_bucket) > 0 ? google_storage_bucket.report_bucket[0].url : ""
}

output "repository_storage_url" {
  value = length(google_storage_bucket.repository_bucket) > 0 ? google_storage_bucket.repository_bucket[0].url : ""
}

output "build_controller_sa_email" {
  value = google_service_account.build_controller_sa.email
}

output "kaniko_sa_email" {
  value = google_service_account.kaniko_sa.email
}

output "tekton_sa_email" {
  value = google_service_account.tekton_sa.email
}

output "jxui_sa_email" {
  value = length(google_service_account.jxui_sa) > 0 ? google_service_account.jxui_sa[0].email : ""
}
