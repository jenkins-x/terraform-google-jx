resource "google_project_service" "dns_api" {
  provider           = "google"
  project            = var.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "externaldns_sa" {
  provider     = "google"
  account_id   = "${var.cluster_name}-${var.externaldns_sa_suffix}"
  display_name = "ExternalDNS service account for ${var.cluster_name}"
}

resource "google_project_iam_member" "externaldns_sa_dns_admin_binding" {
  provider = "google"
  role     = "roles/dns.admin"
  member   = "serviceAccount:${google_service_account.externaldns_sa.email}"
}

resource "google_service_account_iam_binding" "externaldns_sa_workload_binding" {
  provider           = "google"
  service_account_id = "${google_service_account.externaldns_sa.name}"
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.service_name}/${var.cluster_name}-${var.externaldns_sa_suffix}]",
  ]

  depends_on = [
    "google_container_cluster.jx_cluster"
  ]
}
