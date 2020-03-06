// ----------------------------------------------------------------------------
// Enable DNS API
//
// https://www.terraform.io/docs/providers/google/d/google_kms_key_ring.html
// ---------------------------------------------------------------------------
resource "google_project_service" "dns_api" {
  provider           = google
  project            = var.gcp_project
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

// ----------------------------------------------------------------------------
// Setup GCloud Service Accounts
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
resource "google_service_account" "externaldns_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-dn"
  display_name = "ExternalDNS service account for ${var.cluster_name}"
}

resource "google_project_iam_member" "externaldns_sa_dns_admin_binding" {
  provider = google
  role     = "roles/dns.admin"
  member   = "serviceAccount:${google_service_account.externaldns_sa.email}"
}

// ----------------------------------------------------------------------------
// DNS configuration
// ---------------------------------------------------------------------------
resource "google_dns_managed_zone" "externaldns_managed_zone" {
  count    = var.dns_enabled ? 1 : 0
 
  name = "${replace(var.parent_domain, ".", "-")}-managed-zone"
  dns_name = "${var.parent_domain}."
  description = "JX DNS managed zone managed by terraform"
}

resource "google_dns_record_set" "externaldns_record_set" {
  count    = var.dns_enabled ? 1 : 0
  
  name         = google_dns_managed_zone.externaldns_managed_zone[count.index].dns_name
  managed_zone = google_dns_managed_zone.externaldns_managed_zone[count.index].name
  type         = "NS"
  ttl          = 60
  project      = var.gcp_project
  rrdatas      = flatten(google_dns_managed_zone.externaldns_managed_zone[count.index].name_servers)
  depends_on   = [google_dns_managed_zone.externaldns_managed_zone]
}
