resource "google_project_service" "dns_api" {
  provider           = "google"
  project            = var.gcp_project
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
    "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jx_namespace}/${var.cluster_name}-${var.externaldns_sa_suffix}]",
  ]
}

resource "google_dns_managed_zone" "externaldns_managed_zone" {
  name = "${replace(var.parent_domain, ".", "-")}-managed-zone"
  dns_name = "${var.parent_domain}."
  description = "JX DNS managed zone managed by terraform"

  count    = "${var.dns_enabled}"
}

resource "google_dns_record_set" "externaldns_record_set" {
  name         = "${google_dns_managed_zone.externaldns_managed_zone[count.index].dns_name}"
  managed_zone = "${google_dns_managed_zone.externaldns_managed_zone[count.index].name}"
  type         = "NS"
  ttl          = 60
  project      = "${var.gcp_project}"
  rrdatas      = "${flatten(google_dns_managed_zone.externaldns_managed_zone[count.index].name_servers)}"
  depends_on   = ["google_dns_managed_zone.externaldns_managed_zone"]

  count    = "${var.dns_enabled}"
}
