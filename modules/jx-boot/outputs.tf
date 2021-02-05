output "vault_installed" {
  value = helm_release.vault-instance.0.id != "" ? true : false
}
