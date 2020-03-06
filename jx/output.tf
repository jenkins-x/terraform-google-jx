output "gcp_project" {
  value = var.gcp_project
}

output "zone" {
  value = var.zone
}

output "cluster_name" {
  value = var.cluster_name
}

// ----------------------------------------------------------------------------
// Storage (logs, reports, repo, vault, backup)
// ----------------------------------------------------------------------------
output "cluster_location" {
  value = module.cluster.cluster_location
}

output "log_storage_url" {
  value = module.cluster.log_storage_url
}

output "report_storage_url" {
    value = module.cluster.report_storage_url
}

output "repository_storage_url" {
    value = module.cluster.repository_storage_url
}

output "vault_bucket_url" {
  value = module.vault.vault_bucket_url
}

output "backup_bucket_url" {
  value = module.backup.backup_bucket_url
}

// ----------------------------------------------------------------------------
// Velero
// ----------------------------------------------------------------------------
output "velero_sa" {
  value = module.backup.velero_sa
}

// ----------------------------------------------------------------------------
// Vault
// ----------------------------------------------------------------------------
output "vault_name" {
  value = module.vault.vault_name
}

output "vault_bucket_name" {
  value = module.vault.vault_bucket_name
}

output "vault_key" {
  value = module.vault.vault_key
}

output "vault_keyring" {
  value = module.vault.vault_keyring
}

output "vault_sa" {
  value = module.vault.vault_sa
}

// ----------------------------------------------------------------------------
// ExternalDNS
// ----------------------------------------------------------------------------
output "externaldns_ns" {
  value = module.dns.externaldns_ns
}

output "externaldns_dns_name" {
  value = module.dns.externaldns_dns_name
}
