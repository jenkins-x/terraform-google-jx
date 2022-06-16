resource "google_compute_network" "network" {
  name                    = "<my-network-name>" # ex: "preprod", "staging", or "jx-cd"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "<my-subnet-name>"
  ip_cidr_range            = "10.1.0.0/21" # 2048 addresses
  network                  = google_compute_network.network.self_link
  region                   = "us-central1" # your preferred region
  private_ip_google_access = "true"
}

resource "google_compute_router" "nat" {
  name    = "nat-${google_compute_network.network.name}-${google_compute_subnetwork.subnetwork.region}"
  region  = google_compute_subnetwork.subnetwork.region
  network = google_compute_network.network.name
  bgp {
    asn = 64584
  }
}

resource "google_compute_address" "nat" {
  count  = 5
  name   = "nat-${google_compute_network.network.name}-${google_compute_subnetwork.subnetwork.region}-${count.index}"
  region = google_compute_subnetwork.subnetwork.region
}

resource "google_compute_router_nat" "simple" {
  name                               = "${google_compute_network.network.name}-${google_compute_subnetwork.subnetwork.region}"
  router                             = google_compute_router.nat.name
  region                             = google_compute_subnetwork.subnetwork.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

}

# regional, private node, public master gke cluster
module "jx" {
  source                 = "jenkins-x/jx/google"
  gcp_project            = "<my-gcp-project-id>"
  jx2                    = false
  cluster_network        = google_compute_network.network.name
  cluster_subnetwork     = google_compute_subnetwork.subnetwork.self_link
  cluster_name           = "<my-cluster-name>"
  cluster_location       = google_compute_subnetwork.subnetwork.region
  enable_private_nodes   = true
  master_ipv4_cidr_block = "10.0.0.0/28"
  ip_range_pods          = "10.1.64.0/18" # increase to a wider CIDR for larger max_pods_per_node
  ip_range_services      = "10.1.8.0/21"  # 2048 addresses
  max_pods_per_node      = 64             # 2^(25-18) = 128 max nodes

  # list of public ips allowed to communicate with gke master
  master_authorized_networks = [
    {
      cidr_block   = "35.123.45.67/32"
      display_name = "vpn.yourorg.com"
    },
  ]
}
