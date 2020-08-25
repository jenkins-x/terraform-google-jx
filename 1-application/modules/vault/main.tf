// ----------------------------------------------------------------------------
// Setup Kubernetes Vault service accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account_iam.html#google_service_account_iam_member
// https://www.terraform.io/docs/providers/kubernetes/r/service_account.html
// ----------------------------------------------------------------------------
resource "kubernetes_service_account" "vault_sa" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "vault-sa"
    namespace = var.jenkins_x_namespace
    annotations = var.external_vault ? {} : {
      "iam.gke.io/gcp-service-account" = var.vault_sa_email
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }
}
