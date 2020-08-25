output "gcp_project" {
  description = "The GCP project in which the resources got created"
  value       = var.gcp_project
}

output "cluster_location" {
  description = "The location of the created Kubernetes cluster"
  value       = var.cluster_location
}

output "cluster_name" {
  description = "The name of the created Kubernetes cluster"
  value       = module.platform.cluster_name
}

output "log_storage_url" {
  description = "The URL to the bucket for log storage"
  value       = module.platform.log_storage_url
}

output "report_storage_url" {
  description = "The URL to the bucket for report storage"
  value       = module.platform.report_storage_url
}

output "repository_storage_url" {
  description = "The URL to the bucket for artifact storage"
  value       = module.platform.repository_storage_url
}

output "vault_bucket_url" {
  description = "The URL to the bucket for secret storage"
  value       = module.platform.vault_bucket_url
}

output "backup_bucket_url" {
  description = "The URL to the bucket for backup storage"
  value       = module.platform.backup_bucket_url
}

output "jx_requirements" {
  description = "The jx-requirements rendered output"
  value       = module.application.jx_requirements
}

output "connect" {
  description = "The cluster connection string to use once Terraform apply finishes"
  value       = "gcloud container clusters get-credentials ${module.platform.cluster_name} --zone ${var.cluster_location} --project ${var.gcp_project} && jx ns ${var.jenkins_x_namespace} -q"
}
