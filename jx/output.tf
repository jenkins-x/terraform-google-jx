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

output "vault_key" {
  value = module.vault.vault_key
}

output "vault_keyring" {
  value = module.vault.vault_keyring
}

output "vault_name" {
  value = module.vault.vault_name
}

output "vault_sa" {
  value = module.vault.vault_sa
}

output "velero_sa" {
  value = module.backup.velero_sa
}
