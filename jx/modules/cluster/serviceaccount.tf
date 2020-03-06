locals {
  kaniko_sa_gcp_derived_name           = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/kaniko-sa]"
  tekton_sa_gcp_derived_name           = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/tekton-bot]"
  build_controller_sa_gcp_derived_name = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/jenkins-x-controllerbuild]"
}

// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
resource "google_service_account" "storage_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-storage"
  display_name = substr("Storage service account for ${var.cluster_name}", 0, 100)               
}

resource "google_project_iam_member" "storage_sa_storage_object_admin_binding" {
  provider = google
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.storage_sa.email}"
}

// ----------------------------------------------------------------------------
resource "google_service_account" "kaniko_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-ko"
  display_name = substr("Kaniko service account for ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "kaniko_sa_storage_admin_binding" {
  provider = google
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.kaniko_sa.email}"
}

// ----------------------------------------------------------------------------
// jxboot_sa is used to run `jx boot` as a K8s job in the cluster
resource "google_service_account" "jxboot_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-jxboot"
  display_name = substr("jx-boot service account for ${var.cluster_name}", 0, 100) 
}

resource "google_project_iam_member" "jxboot_sa_dns_admin_binding" {
  provider = google
  role     = "roles/dns.admin"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

resource "google_project_iam_member" "jxboot_sa_project_viewer_binding" {
  provider = google
  role     = "roles/viewer"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

resource "google_project_iam_member" "jxboot_sa_service_account_key_binding" {
  provider = google
  role     = "roles/iam.serviceAccountKeyAdmin"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

resource "google_project_iam_member" "jxboot_sa_storage_admin_binding" {
  provider = google
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.jxboot_sa.email}"
}

// ----------------------------------------------------------------------------
// Setup K8s Tekton service account
//
// https://www.terraform.io/docs/providers/google/r/google_service_account_iam.html#google_service_account_iam_member
// https://www.terraform.io/docs/providers/kubernetes/r/service_account.html
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "tekton_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.storage_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.tekton_sa_gcp_derived_name
}

resource "kubernetes_service_account" "tekton_sa" {
  automount_service_account_token = true
  metadata {
    name = "tekton-bot"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.storage_sa.email
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
// Setup K8s build controller service account
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "build_controller_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.storage_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.build_controller_sa_gcp_derived_name
}

resource "kubernetes_service_account" "build_controller_sa" {
  automount_service_account_token = true
  metadata {
    name = "jenkins-x-controllerbuild"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.storage_sa.email
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
// Setup K8s Kaniko service account
// ----------------------------------------------------------------------------
resource "kubernetes_service_account" "kaniko_sa" {
  automount_service_account_token = true
  metadata {
    name = "kaniko-sa"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.kaniko_sa.email
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

resource "google_service_account_iam_member" "kaniko_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.kaniko_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.kaniko_sa_gcp_derived_name
}
