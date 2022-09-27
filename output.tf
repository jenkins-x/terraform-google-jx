output "gcp_project" {
  description = "The GCP project in which the resources got created"
  value       = var.gcp_project
}



output "log_storage_url" {
  description = "The URL to the bucket for log storage"
  value       = module.jx.log_storage_url
}

output "report_storage_url" {
  description = "The URL to the bucket for report storage"
  value       = module.jx.report_storage_url
}

output "repository_storage_url" {
  description = "The URL to the bucket for artifact storage"
  value       = module.jx.repository_storage_url
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
  value       = module.jx.tekton_sa_email
}

output "tekton_sa_name" {
  description = "The Tekton service account name, useful to provide further IAM bindings"
  value       = module.jx.tekton_sa_name
}


output "jx_requirements" {
  description = "The jx-requirements rendered output"
  value       = local.content
}



output "externaldns_ns" {
  description = "ExternalDNS nameservers"
  value       = module.dns.externaldns_ns
}

output "externaldns_dns_name" {
  description = "ExternalDNS name"
  value       = module.dns.externaldns_dns_name
}
