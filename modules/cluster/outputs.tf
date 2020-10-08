output "cluster_name" {
  value = google_container_cluster.jx_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.jx_cluster.location
}

output "cluster_endpoint" {
  value = google_container_cluster.jx_cluster.endpoint
}

output "cluster_client_certificate" {
  value = length(google_container_cluster.jx_cluster.master_auth) > 0 ? google_container_cluster.jx_cluster.master_auth[0].client_certificate : ""
}

output "client_client_key" {
  value = length(google_container_cluster.jx_cluster.master_auth) > 0 ? google_container_cluster.jx_cluster.master_auth[0].client_key : ""
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

