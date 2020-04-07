output "gcp_project" {
  description = "The GCP project in which the resources got created in"
  value       = var.gcp_project
}

output "zone" {
  description = "The zone of the created Kubernetes cluster"
  value       = var.zone
}

output "cluster_name" {
  description = "The name of the created Kubernetes cluster"
  value       = local.cluster_name
}

output "log_storage_url" {
  description = "The URL to the bucket for log storage"
  value       = module.cluster.log_storage_url
}

output "report_storage_url" {
  description = "The URL to the bucket for report storage"
  value       = module.cluster.report_storage_url
}

output "repository_storage_url" {
  description = "The URL to the bucket for artefact storage"
  value       = module.cluster.repository_storage_url
}

output "vault_bucket_url" {
  description = "The URL to the bucket for secret storage"
  value       = module.vault.vault_bucket_url
}

output "backup_bucket_url" {
  description = "The URL to the bucket for backup storage"
  value       = module.backup.backup_bucket_url
}
