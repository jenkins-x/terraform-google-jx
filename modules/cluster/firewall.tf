resource "google_compute_firewall" "gke_master_allow_certmanager_webhook" {
  count   = local.enable_private_cluster_config ? 1 : 0
  name    = "${var.cluster_name}-master-webhooks"
  network = var.cluster_network

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = [var.master_ipv4_cidr_block]
}

resource "google_compute_firewall" "gke_master_allow_nginx_tekton_webhook" {
  count   = local.enable_private_cluster_config ? 1 : 0
  name    = "vault-webhook-gke-${var.cluster_name}"
  network = var.cluster_network

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = [var.master_ipv4_cidr_block]
}

resource "google_compute_firewall" "gke_master_allow_istio_webhook" {
  count   = local.enable_private_cluster_config ? 1 : 0
  name    = "istio-webhook-${var.cluster_name}"
  network = var.cluster_network

  allow {
    protocol = "tcp"
    ports    = ["15017", "10250", "8080", "15000", "9100"]
  }

  source_ranges = [var.master_ipv4_cidr_block]
}
