provider "google" {
    project = "<my-gcp-project-id>"
    zone = "<my-zone-or-region>"
    version = ">= 2.12.0"
}

provider "google-beta" {
    project = "<my-gcp-project-id>"
    zone = "<my-zone-or-region>"
    version = ">= 2.12.0"
}

module "jx" {
    source = "jenkins-x/jx/google"
    gcp_project = "<my-gcp-project-id>"
    cluster_name = "<my-cluster-name>"
    zone = "<my-zone-or-region>"
}

resource "google_container_node_pool" "large_nodes" {
    provider           = google-beta
    name               = "large-nodes"
    location           = "<my-zone-or-region>"
    cluster            = module.jx.cluster_name
    initial_node_count = 1

    node_config {
        preemptible  = true
        machine_type = "n2-standard-2"

        oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.full_control",
        "https://www.googleapis.com/auth/service.management",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        ]

        workload_metadata_config {
        node_metadata = "GKE_METADATA_SERVER"
        }

        labels = {
            preemptible = "true"
        }
    }

    autoscaling {
        min_node_count = 1
        max_node_count = 3
    }

    management {
        auto_repair  = "true"
        auto_upgrade = "false"
    }
}
