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
  project  = var.gcp_project
  role     = "roles/dns.admin"
  member   = "serviceAccount:${google_service_account.dns_sa.email}"
}

// ----------------------------------------------------------------------------
// DNS configuration
// ----------------------------------------------------------------------------

// if we have a subdomain managed the zone here and add recordsets to the apex zone
resource "google_dns_managed_zone" "externaldns_managed_zone_with_sub" {
  count = var.apex_domain != "" && var.subdomain != "" ? 1 : 0

  name        = "${replace(var.subdomain, ".", "-")}-${replace(var.apex_domain, ".", "-")}-sub"
  dns_name    = "${var.subdomain}.${var.apex_domain}."
  description = "JX DNS subdomain zone managed by terraform"

  force_destroy = true
}

resource "google_dns_record_set" "externaldns_record_set_with_sub" {
  count = var.apex_domain != "" && var.subdomain != "" && var.apex_domain_integration_enabled ? 1 : 0

  name         = google_dns_managed_zone.externaldns_managed_zone_with_sub[count.index].dns_name
  managed_zone = replace(var.apex_domain, ".", "-")
  type         = "NS"
  ttl          = 60
  project      = var.apex_domain_gcp_project
  rrdatas      = flatten(google_dns_managed_zone.externaldns_managed_zone_with_sub[count.index].name_servers)
  depends_on   = [google_dns_managed_zone.externaldns_managed_zone_with_sub]
}

// ----------------------------------------------------------------------------
// Create Kubernetes service accounts for ExternalDNS
// See https://github.com/kubernetes-sigs/external-dns
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "exdns_external_dns_workload_identity_user" {
  count              = var.jx2 ? 1 : 0
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/exdns-external-dns]"
}

// ----------------------------------------------------------------------------
// Create Kubernetes service accounts for ExternalDNS
// See https://github.com/kubernetes-sigs/external-dns
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "exdns_external_dns_workload_identity_userv3" {
  count              = var.jx2 ? 0 : 1
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.jenkins_x_namespace}/external-dns]"
}

// ----------------------------------------------------------------------------
// Create Kubernetes service accounts for ExternalDNS
// See https://github.com/kubernetes-sigs/external-dns
// ----------------------------------------------------------------------------
resource "google_service_account_iam_member" "certmanager_workload_identity_userv3" {
  count              = var.jx2 ? 0 : 1
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[cert-manager/cert-manager]"
}

resource "kubernetes_service_account" "exdns-external-dns" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "exdns-external-dns"
    namespace = var.jenkins_x_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.dns_sa.email
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
  count = var.jx2 ? 1 : 0
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

resource "google_service_account_iam_member" "cm_cert_manager_workload_identity_user" {
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.cert-manager-namespace}/cm-cert-manager]"
}

resource "kubernetes_service_account" "cm-cert-manager" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "cm-cert-manager"
    namespace = var.cert-manager-namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.dns_sa.email
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

resource "google_service_account_iam_member" "cm_cainjector_workload_identity_user" {
  count              = var.jx2 ? 1 : 0
  provider           = google
  service_account_id = google_service_account.dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.cert-manager-namespace}/cm-cainjector]"
}

resource "kubernetes_service_account" "cm-cainjector" {
  count                           = var.jx2 ? 1 : 0
  automount_service_account_token = true
  metadata {
    name      = "cm-cainjector"
    namespace = var.cert-manager-namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.dns_sa.email
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
