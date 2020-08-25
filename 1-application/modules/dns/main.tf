// ----------------------------------------------------------------------------
// Create Kubernetes service accounts for ExternalDNS
// See https://github.com/kubernetes-sigs/external-dns
// ----------------------------------------------------------------------------
resource "kubernetes_service_account" "exdns-external-dns" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "exdns-external-dns"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.dns_sa_email
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

// ----------------------------------------------------------------------------
// Create Kubernetes namespace and service accounts for cert-manager
// See https://github.com/jetstack/cert-manager
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = var.cert-manager-namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_service_account" "cm-cert-manager" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "cm-cert-manager"
    namespace = var.cert-manager-namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.dns_sa_email
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
    kubernetes_namespace.cert-manager
  ]
}

resource "kubernetes_service_account" "cm-cainjector" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "cm-cainjector"
    namespace = var.cert-manager-namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.dns_sa_email
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
    kubernetes_namespace.cert-manager
  ]
}
