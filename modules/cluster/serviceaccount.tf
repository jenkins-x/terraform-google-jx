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
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.build_controller_sa.email}"
}

resource "google_project_iam_member" "build_controller_sa_storage_admin_binding" {
  provider = google
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
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.tekton_sa.email}"
}

resource "google_project_iam_member" "tekton_sa_storage_admin_binding" {
  provider = google
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.tekton_sa.email}"
}

resource "google_project_iam_member" "tekton_sa_project_viewer_binding" {
  provider = google
  role     = "roles/viewer"
  member   = "serviceAccount:${google_service_account.tekton_sa.email}"
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

resource "kubernetes_service_account" "build_controller_sa" {
  automount_service_account_token = true
  metadata {
    name = "jenkins-x-controllerbuild"
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
    google_container_node_pool.jx_node_pool,
  ]
}

// ----------------------------------------------------------------------------
// Kaniko
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
  depends_on = [
    google_container_node_pool.jx_node_pool,
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
  automount_service_account_token = true
  metadata {
    name = "tekton-bot"
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
    google_container_node_pool.jx_node_pool,
  ]
}
