// ----------------------------------------------------------------------------
// Setup Kubernetes Velero namespace and service account
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "velero_namespace" {
  count = var.enable_backup ? 1 : 0

  metadata {
    name = var.velero_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_service_account" "velero_sa" {
  count = var.enable_backup ? 1 : 0

  automount_service_account_token = true
  metadata {
    name      = "velero-server"
    namespace = var.velero_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.velero_sa_email
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }

  depends_on = [
    kubernetes_namespace.velero_namespace
  ]
}