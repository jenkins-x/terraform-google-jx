# VPC Network
resource "google_compute_network" "vpc_network" {
  count                   = var.cluster_network == null ? 1 : 0
  name                    = "${var.cluster_name}-network"
  project                 = var.gcp_project
  auto_create_subnetworks = false
}

# subnet for vpc
resource "google_compute_subnetwork" "vpc_subnet" {
  count         = var.cluster_network == null ? 1 : 0
  name          = "${var.cluster_name}-subnet"
  project       = var.gcp_project
  ip_cidr_range = "192.168.1.0/24"
  region        = var.cluster_location
  network       = google_compute_network.vpc_network[0].id
}

# firewall
resource "google_compute_firewall" "firewall" {
  count         = var.cluster_network == null ? 1 : 0
  name          = "${var.cluster_name}-ingress"
  project       = var.gcp_project
  network       = google_compute_network.vpc_network[0].id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "15017", "10250", "8443"]
    # 22 because it was in the google example: default
    # 443: because of nodes
    # 15017 and 10250 because of istio and knative
    # 8443 for k8s webhooks: See https://kubernetes.slack.com/archives/C9MBGQJRH/p1602278437372600?thread_ts=1602256346.346200&cid=C9MBGQJRH
  }

  target_tags = ["worker-node"]
}

# external IP for clusterIP
resource "google_compute_address" "nat_ip" {
  count   = var.cluster_network == null ? 1 : 0
  name    = "${var.cluster_name}-nat"
  project = var.gcp_project
  region  = var.cluster_location
}

# cloud router (to be used by cloud nat)
resource "google_compute_router" "nat_router" {
  count   = var.cluster_network == null ? 1 : 0
  name    = "${var.cluster_name}-nat-router"
  project = var.gcp_project
  region  = var.cluster_location
  network = google_compute_network.vpc_network[0].id
}

# cloud nat
resource "google_compute_router_nat" "nat" {
  count                              = var.cluster_network == null ? 1 : 0
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.nat_router[0].name
  region                             = google_compute_router.nat_router[0].region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_ip.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
