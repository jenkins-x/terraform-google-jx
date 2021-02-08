output "vault_installed" {
  value = var.install_vault ? (helm_release.vault-instance.0.id != "" ? true : false) : false
}
