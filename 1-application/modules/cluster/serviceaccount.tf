// ----------------------------------------------------------------------------
// Build controller
resource "kubernetes_service_account" "build_controller_sa" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "jenkins-x-controllerbuild"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.build_controller_sa_email
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
// Kaniko
resource "kubernetes_service_account" "kaniko_sa" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "kaniko-sa"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.kaniko_sa_email
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
// Tekton
resource "kubernetes_service_account" "tekton_sa" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "tekton-bot"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.tekton_sa_email
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
// UI
resource "kubernetes_service_account" "jxui_sa" {
  count                           = var.create_ui_sa && var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "jxui-sa"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.jxui_sa_email
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
