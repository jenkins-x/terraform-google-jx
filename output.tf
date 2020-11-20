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
  value       = length(module.vault) > 0 ? module.vault[0].vault_bucket_url : ""
}

output "backup_bucket_url" {
  description = "The URL to the bucket for backup storage"
  value       = module.backup.backup_bucket_url
}

output "tekton_sa_email" {
  description = "The Tekton service account email address, useful to provide further IAM bindings"
  value       = module.cluster.tekton_sa_email
}

output "tekton_sa_name" {
  description = "The Tekton service account name, useful to provide further IAM bindings"
  value       = module.cluster.tekton_sa_name
}


output "jx_requirements" {
  description = "The jx-requirements rendered output"
  value       = local.content
}

output "connect" {
  description = "The cluster connection string to use once Terraform apply finishes"
  value       = "gcloud container clusters get-credentials ${local.cluster_name} --zone ${var.cluster_location} --project ${var.gcp_project}"
}

output "externaldns_ns" {
  description = "ExternalDNS nameservers"
  value       = module.dns.externaldns_ns
}

output "externaldns_dns_name" {
  description = "ExternalDNS name"
  value       = module.dns.externaldns_dns_name
}