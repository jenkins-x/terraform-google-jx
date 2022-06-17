// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
// Build controller
resource "google_service_account" "build_controller_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-bc"
  display_name = substr("Build controller service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "build_controller_sa_storage_object_admin_binding" {
  provider = google
  project  = var.gcp_project
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.build_controller_sa.email}"
}

resource "google_project_iam_member" "build_controller_sa_storage_admin_binding" {
  provider = google
  project  = var.gcp_project
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.build_controller_sa.email}"
}

// ----------------------------------------------------------------------------
// Kaniko
resource "google_service_account" "kaniko_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-ko"
  display_name = substr("Kaniko service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "kaniko_sa_storage_admin_binding" {
  provider = google
  project  = var.gcp_project
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.kaniko_sa.email}"
}

// ----------------------------------------------------------------------------
// Tekton
resource "google_service_account" "tekton_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-tekton"
  display_name = substr("Tekton service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "tekton_sa_storage_object_admin_binding" {
  provider = google
  project  = var.gcp_project
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.tekton_sa.email}"
}

resource "google_project_iam_member" "tekton_sa_storage_admin_binding" {
  provider = google
  project  = var.gcp_project
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.tekton_sa.email}"
}

resource "google_project_iam_member" "tekton_sa_project_viewer_binding" {
  provider = google
  project  = var.gcp_project
  role     = "roles/viewer"
  member   = "serviceAccount:${google_service_account.tekton_sa.email}"
}

// ----------------------------------------------------------------------------
// UI
resource "google_service_account" "jxui_sa" {
  count = var.create_ui_sa ? 1 : 0

  provider     = google
  account_id   = "${var.cluster_name}-jxui"
  display_name = substr("Jenkins X UI service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "ui_sa_storage_admin_binding" {
  count    = var.create_ui_sa ? 1 : 0
  project  = var.gcp_project
  provider = google
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.jxui_sa[0].email}"
}

resource "google_project_iam_member" "ui_sa_storage_object_admin_binding" {
  count    = var.create_ui_sa ? 1 : 0
  project  = var.gcp_project
  provider = google
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.jxui_sa[0].email}"
}

// ----------------------------------------------------------------------------
// Setup Kubernetes service accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account_iam.html#google_service_account_iam_member
// https://www.terraform.io/docs/providers/kubernetes/r/service_account.html
// ----------------------------------------------------------------------------
// Build controller
resource "google_service_account_iam_member" "build_controller_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.build_controller_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/jenkins-x-controllerbuild]"
}

resource "google_service_account_iam_member" "bucketrepo_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.build_controller_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/bucketrepo-bucketrepo]"
}

resource "kubernetes_service_account" "build_controller_sa" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "jenkins-x-controllerbuild"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.build_controller_sa.email
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
    google_container_cluster.jx_cluster,
  ]
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
  depends_on = [
    google_container_cluster.jx_cluster,
  ]
}

resource "google_service_account_iam_member" "kaniko_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.kaniko_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/kaniko-sa]"
}

// ----------------------------------------------------------------------------
// Tekton
resource "google_service_account_iam_member" "tekton_sa_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.tekton_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/tekton-bot]"
}

resource "kubernetes_service_account" "tekton_sa" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "tekton-bot"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.tekton_sa.email
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
    google_container_cluster.jx_cluster,
  ]
}

// ----------------------------------------------------------------------------
// UI
resource "google_service_account_iam_member" "jxui_sa_workload_identity_user" {
  count = var.create_ui_sa ? 1 : 0

  provider           = google
  service_account_id = google_service_account.jxui_sa[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/jx-pipelines-visualizer]"
}

// ----------------------------------------------------------------------------
// Boot
resource "google_service_account" "boot_sa" {
  count = var.jx2 ? 0 : 1

  provider     = google
  account_id   = "${var.cluster_name}-boot"
  display_name = substr("jx boot service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "boot_sa_storage_object_admin_binding" {
  count    = var.jx2 ? 0 : 1
  project  = var.gcp_project
  provider = google
  role     = "roles/secretmanager.admin"
  member   = "serviceAccount:${google_service_account.boot_sa[count.index].email}"
}

resource "google_service_account_iam_member" "boot_sa_workload_identity_user" {
  count = var.jx2 ? 0 : 1

  provider           = google
  service_account_id = google_service_account.boot_sa[count.index].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[jx-git-operator/jx-boot-job]"
}
