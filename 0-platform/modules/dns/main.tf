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
// Setup GCloud Service Accounts for DNS
//
// https://www.terraform.io/docs/providers/google/r/google_service_account.html
// https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
// ----------------------------------------------------------------------------
resource "google_service_account" "dns_sa" {
  provider     = google
  account_id   = "${var.cluster_name}-dn"
  display_name = substr("ExternalDNS service account for cluster ${var.cluster_name}", 0, 100)
}

resource "google_project_iam_member" "externaldns_sa_dns_admin_binding" {
  provider = google
  role     = "roles/dns.admin"
  member   = "serviceAccount:${google_service_account.dns_sa.email}"
}

// ----------------------------------------------------------------------------
// DNS configuration
// ----------------------------------------------------------------------------
# For now we assume that the user creates and manages the managed zones himself and
# set it is setup correctly.
#
# If we create the managed zone here a 'terraform destroy' will fail if there are
# record sets in the zone. 
# See also https://github.com/terraform-providers/terraform-provider-google/issues/1572
#
# Also creating the managed zone here means that the user cannot directly execute `jx boot`
# after `terraform apply` since he would need to update his DNS settings and ensure the DNS
# changes have propagated.

# resource "google_dns_managed_zone" "externaldns_managed_zone" {
#   count    = local.dns_enabled ? 1 : 0

#   name = "${replace(var.parent_domain, ".", "-")}-managed-zone"
#   dns_name = "${var.parent_domain}."
#   description = "JX DNS managed zone managed by terraform"
# }

# resource "google_dns_record_set" "externaldns_record_set" {
#   count    = local.dns_enabled ? 1 : 0

#   name         = google_dns_managed_zone.externaldns_managed_zone[count.index].dns_name
#   managed_zone = google_dns_managed_zone.externaldns_managed_zone[count.index].name
#   type         = "NS"
#   ttl          = 60
#   project      = var.gcp_project
#   rrdatas      = flatten(google_dns_managed_zone.externaldns_managed_zone[count.index].name_servers)
#   depends_on   = [google_dns_managed_zone.externaldns_managed_zone]
# }

// ----------------------------------------------------------------------------
// Create Kubernetes service accounts for ExternalDNS
// See https://github.com/kubernetes-sigs/external-dns
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "external_dns_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/external-dns]"
}

// ----------------------------------------------------------------------------
// Create Kubernetes namespace and service accounts for cert-manager
// See https://github.com/jetstack/cert-manager
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "cm_cert_manager_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.cert-manager-namespace}/cm-cert-manager]"
}

resource "google_service_account_iam_member" "cm_cainjector_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.cert-manager-namespace}/cm-cainjector]"
}