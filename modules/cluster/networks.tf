# VPC Network
resource "google_compute_network" "vpc_network" {
    name = "test-network2"
    project = var.gcp_project
    auto_create_subnetworks = false
}

# subnet for vpc
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "subnet-second"
  project       = var.gcp_project
  ip_cidr_range = "192.168.2.0/24"
  region        = var.cluster_location
  network       = google_compute_network.vpc_network.id
}

# firewall
resource "google_compute_firewall" "firewall" {
  name    = "allow-ssh2"
  project = var.gcp_project
  network = google_compute_network.vpc_network.id
  source_ranges = "35.236.240.0/20"

  allow {
    protocol = "tcp"
    ports    = ["22",]
  }

  target_tags = ["ssh"]
}


# cloud router (to be used by cloud nat)
resource "google_compute_router" "nat_router" {
  name    = format("%s-nat-router", var.cluster_name)
  project = var.gcp_project
  region  = var.cluster_location
  network = google_compute_network.vpc_network.id
}


# cloud nat
resource "google_compute_router_nat" "nat" {
  name                               = "nat-config2"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}