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
  value       = local.cluster_name
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = module.cluster.cluster_ca_certificate
}

output "cluster_endpoint" {
  description = "Cluster ednpoint"
  value       = module.cluster.cluster_endpoint
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
  description = "The URL to the bucket for artifact storage"
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

output "connect" {
  description = "The cluster connection string to use once Terraform apply finishes"
  value       = "gcloud container clusters get-credentials ${local.cluster_name} --zone ${var.cluster_location} --project ${var.gcp_project} && jx ns ${var.jenkins_x_namespace} -q"
}

output "access_token" {
  value = data.google_client_config.default.access_token
}

output "build_controller_sa_email" {
  value = module.cluster.build_controller_sa_email
}

output "kaniko_sa_email" {
  value = module.cluster.kaniko_sa_email
}

output "tekton_sa_email" {
  value = module.cluster.tekton_sa_email
}

output "jxui_sa_email" {
  value = module.cluster.jxui_sa_email
}

output "dns_sa_email" {
  value = module.dns.dns_sa_email
}

output "vault_sa" {
  value = module.vault.vault_sa
}

output "vault_sa_email" {
  value = module.vault.vault_sa
}

output "vault_name" {
  value = module.vault.vault_name
}

output "vault_keyring" {
  value = module.vault.vault_keyring
}

output "vault_key" {
  value = module.vault.vault_key
}

output "vault_bucket_name" {
  value = module.vault.vault_bucket_name
}

output "backup_velero_sa" {
  value = module.backup.velero_sa
}

output "backup_velero_sa_email" {
  value = module.backup.velero_sa_email
}
