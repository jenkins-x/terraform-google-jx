output "gcp_project" {
  value = var.gcp_project
}

output "zone" {
  value = var.zone
}

output "cluster_name" {
  value = var.cluster_name
}

output "lts_bucket_url" {
  value = module.cluster.lts_bucket_url
}

output "backup_bucket_url" {
  value = module.backup.backup_bucket_url
}

output "vault_bucket_name" {
  value = module.vault.vault_bucket_name
}
