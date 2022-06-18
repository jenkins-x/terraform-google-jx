// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project"
  type        = string
}

variable "cluster_location" {
  description = "The location (region or zone) in which the cluster master will be created. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region"
  type        = string
}

variable "cluster_network" {
  description = "The name of the network (VPC) to which the cluster is connected"
  type        = string
  default     = "default"
}

variable "cluster_subnetwork" {
  description = "The name of the subnetwork to which the cluster is connected. Leave blank when using the 'default' vpc to generate a subnet for your cluster"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
}

variable "cluster_id" {
  description = "A random generated to uniqly name cluster resources"
  type        = string
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
// storage
variable "bucket_location" {
  description = "Bucket location for storage"
  type        = string
  default     = "US"
}

variable "enable_log_storage" {
  description = "Flag to enable or disable storage of build logs in a cloud bucket"
  type        = bool
  default     = true
}

variable "enable_report_storage" {
  description = "Flag to enable or disable storage of build reports in a cloud bucket"
  type        = bool
  default     = true
}

variable "enable_repository_storage" {
  description = "Flag to enable or disable storage of artifacts in a cloud bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed"
  type        = bool
  default     = false
}

// cluster configuration
variable "enable_private_endpoint" {
  type        = bool
  description = "(Beta) Whether the master's internal IP address is used as the cluster endpoint. Requires VPC-native"
  default     = false
}

variable "enable_private_nodes" {
  type        = bool
  description = "(Beta) Whether nodes have internal IP addresses only. Requires VPC-native"
  default     = false
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The IP range in CIDR notation to use for the hosted master network. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet"
  default     = "10.0.0.0/28"
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically allowlists)."
  default     = []
}

variable "ip_range_pods" {
  type        = string
  description = "The IP range in CIDR notation to use for pods. Set to /netmask (e.g. /18) to have a range chosen with a specific netmask. Enables VPC-native"
  default     = ""
}

# Max Pods per Node --- CIDR Range per Node
# 8                     /28
# 9–16                  /27
# 17–32                 /26
# 33–64                 /25
# 65–110                /24
variable "max_pods_per_node" {
  type        = number
  description = "Max gke nodes = 2^($CIDR_RANGE_PER_NODE-$POD_NETWORK_CIDR) (see [gke docs](https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr))"
  default     = 64 # 2^(25-21) = 16 max nodes
}

variable "ip_range_services" {
  type        = string
  description = "The IP range in CIDR notation use for services. Set to /netmask (e.g. /21) to have a range chosen with a specific netmask. Enables VPC-native"
  default     = ""
}

variable "node_machine_type" {
  description = "Node type for the Kubernetes cluster"
  type        = string
}

// https://cloud.google.com/compute/docs/machine-types
variable "machine_types_cpu" {
  type = map(any)
  default = {
    "e2-standard-2"  = 2
    "e2-standard-4"  = 4
    "e2-standard-8"  = 8
    "e2-standard-16" = 16
    "e2-standard-32" = 32

    "e2-highmem-2"  = 2
    "e2-highmem-4"  = 4
    "e2-highmem-8"  = 8
    "e2-highmem-16" = 16

    "e2-highcpu-2"  = 2
    "e2-highcpu-4"  = 4
    "e2-highcpu-8"  = 8
    "e2-highcpu-16" = 16
    "e2-highcpu-32" = 32

    "n2-standard-2"  = 2
    "n2-standard-4"  = 4
    "n2-standard-8"  = 8
    "n2-standard-16" = 16
    "n2-standard-32" = 32
    "n2-standard-48" = 48
    "n2-standard-64" = 64
    "n2-standard-80" = 80

    "n2-highmem-2"  = 2
    "n2-highmem-4"  = 4
    "n2-highmem-8"  = 8
    "n2-highmem-16" = 16
    "n2-highmem-32" = 32
    "n2-highmem-48" = 48
    "n2-highmem-64" = 64
    "n2-highmem-80" = 80

    "n2-highcpu-2"  = 2
    "n2-highcpu-4"  = 4
    "n2-highcpu-8"  = 8
    "n2-highcpu-16" = 16
    "n2-highcpu-32" = 32
    "n2-highcpu-48" = 48
    "n2-highcpu-64" = 64
    "n2-highcpu-80" = 80

    "n2d-standard-2"   = 2
    "n2d-standard-4"   = 4
    "n2d-standard-8"   = 8
    "n2d-standard-16"  = 16
    "n2d-standard-32"  = 32
    "n2d-standard-48"  = 48
    "n2d-standard-64"  = 64
    "n2d-standard-80"  = 80
    "n2d-standard-96"  = 96
    "n2d-standard-128" = 128
    "n2d-standard-224" = 224

    "n2d-highmem-2"  = 2
    "n2d-highmem-4"  = 4
    "n2d-highmem-8"  = 8
    "n2d-highmem-16" = 16
    "n2d-highmem-32" = 32
    "n2d-highmem-48" = 48
    "n2d-highmem-64" = 64
    "n2d-highmem-80" = 80
    "n2d-highmem-96" = 96

    "n2d-highcpu-2"   = 2
    "n2d-highcpu-4"   = 4
    "n2d-highcpu-8"   = 8
    "n2d-highcpu-16"  = 16
    "n2d-highcpu-32"  = 32
    "n2d-highcpu-48"  = 48
    "n2d-highcpu-64"  = 64
    "n2d-highcpu-80"  = 80
    "n2d-highcpu-96"  = 96
    "n2d-highcpu-128" = 128
    "n2d-highcpu-224" = 224

    "c2-standard-4"  = 4
    "c2-standard-8"  = 8
    "c2-standard-16" = 16
    "c2-standard-30" = 30
    "c2-standard-60" = 60

    "n1-standard-1"  = 1
    "n1-standard-2"  = 2
    "n1-standard-4"  = 4
    "n1-standard-8"  = 8
    "n1-standard-16" = 16
    "n1-standard-32" = 32
    "n1-standard-64" = 64
    "n1-standard-96" = 96

    "n1-highmem-2"  = 2
    "n1-highmem-4"  = 4
    "n1-highmem-8"  = 8
    "n1-highmem-16" = 16
    "n1-highmem-32" = 32
    "n1-highmem-64" = 64
    "n1-highmem-96" = 96

    "n1-highcpu-2"  = 2
    "n1-highcpu-4"  = 4
    "n1-highcpu-8"  = 8
    "n1-highcpu-16" = 16
    "n1-highcpu-32" = 32
    "n1-highcpu-64" = 64
    "n1-highcpu-96" = 96
  }
}

variable "machine_types_memory" {
  type = map(any)
  default = {
    "e2-standard-2"  = 8
    "e2-standard-4"  = 16
    "e2-standard-8"  = 32
    "e2-standard-16" = 64
    "e2-standard-32" = 128

    "e2-highmem-2"  = 16
    "e2-highmem-4"  = 32
    "e2-highmem-8"  = 64
    "e2-highmem-16" = 128

    "e2-highcpu-2"  = 2
    "e2-highcpu-4"  = 4
    "e2-highcpu-8"  = 8
    "e2-highcpu-16" = 16
    "e2-highcpu-32" = 32

    "n2-standard-2"  = 8
    "n2-standard-4"  = 16
    "n2-standard-8"  = 32
    "n2-standard-16" = 64
    "n2-standard-32" = 128
    "n2-standard-48" = 192
    "n2-standard-64" = 256
    "n2-standard-80" = 320

    "n2-highmem-2"  = 16
    "n2-highmem-4"  = 32
    "n2-highmem-8"  = 64
    "n2-highmem-16" = 128
    "n2-highmem-32" = 256
    "n2-highmem-48" = 384
    "n2-highmem-64" = 512
    "n2-highmem-80" = 640

    "n2-highcpu-2"  = 2
    "n2-highcpu-4"  = 4
    "n2-highcpu-8"  = 8
    "n2-highcpu-16" = 16
    "n2-highcpu-32" = 32
    "n2-highcpu-48" = 48
    "n2-highcpu-64" = 64
    "n2-highcpu-80" = 80

    "n2d-standard-2"   = 2
    "n2d-standard-4"   = 4
    "n2d-standard-8"   = 8
    "n2d-standard-16"  = 16
    "n2d-standard-32"  = 32
    "n2d-standard-48"  = 48
    "n2d-standard-64"  = 64
    "n2d-standard-80"  = 80
    "n2d-standard-96"  = 96
    "n2d-standard-128" = 128
    "n2d-standard-224" = 224

    "n2d-highmem-2"  = 16
    "n2d-highmem-4"  = 32
    "n2d-highmem-8"  = 64
    "n2d-highmem-16" = 128
    "n2d-highmem-32" = 256
    "n2d-highmem-48" = 384
    "n2d-highmem-64" = 512
    "n2d-highmem-80" = 640
    "n2d-highmem-96" = 768

    "n2d-highcpu-2"   = 2
    "n2d-highcpu-4"   = 4
    "n2d-highcpu-8"   = 8
    "n2d-highcpu-16"  = 16
    "n2d-highcpu-32"  = 32
    "n2d-highcpu-48"  = 48
    "n2d-highcpu-64"  = 64
    "n2d-highcpu-80"  = 80
    "n2d-highcpu-96"  = 96
    "n2d-highcpu-128" = 128
    "n2d-highcpu-224" = 224

    "c2-standard-4"  = 16
    "c2-standard-8"  = 32
    "c2-standard-16" = 64
    "c2-standard-30" = 120
    "c2-standard-60" = 240

    "n1-standard-1"  = 3.75
    "n1-standard-2"  = 7.50
    "n1-standard-4"  = 15
    "n1-standard-8"  = 30
    "n1-standard-16" = 60
    "n1-standard-32" = 120
    "n1-standard-64" = 240
    "n1-standard-96" = 360

    "n1-highmem-2"  = 13
    "n1-highmem-4"  = 26
    "n1-highmem-8"  = 52
    "n1-highmem-16" = 104
    "n1-highmem-32" = 208
    "n1-highmem-64" = 416
    "n1-highmem-96" = 624

    "n1-highcpu-2"  = 1.8
    "n1-highcpu-4"  = 3.6
    "n1-highcpu-8"  = 7.2
    "n1-highcpu-16" = 14.4
    "n1-highcpu-32" = 28.8
    "n1-highcpu-64" = 57.6
    "n1-highcpu-96" = 86.4
  }
}

variable "min_node_count" {
  description = "Minimum number of cluster nodes"
  type        = number
  default     = 3
}

variable "max_node_count" {
  description = "Maximum number of cluster nodes"
  type        = number
  default     = 5
}

variable "release_channel" {
  description = "The GKE release channel to subscribe to.  See https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels"
  type        = string
  default     = "UNSPECIFIED"
}

variable "resource_labels" {
  description = "Set of labels to be applied to the cluster"
  type        = map(any)
  default     = {}
}

variable "node_preemptible" {
  description = "Use preemptible nodes"
  type        = bool
  default     = false
}

variable "node_spot" {
  description = "Use spot nodes"
  type        = bool
  default     = false
}

variable "node_disk_type" {
  description = "Node disk type (pd-ssd or pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "node_disk_size" {
  description = "Node disk size in GB"
  type        = string
  default     = "100"
}

variable "enable_kubernetes_alpha" {
  type    = bool
  default = false
}

variable "enable_legacy_abac" {
  type    = bool
  default = false
}

variable "enable_shielded_nodes" {
  type    = bool
  default = true
}

variable "auto_repair" {
  type    = bool
  default = false
}

variable "auto_upgrade" {
  type    = bool
  default = false
}

variable "monitoring_service" {
  description = "The monitoring service to use. Can be monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "logging_service" {
  description = "The logging service to use. Can be logging.googleapis.com, logging.googleapis.com/kubernetes (beta) and none"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

// service accounts
variable "create_ui_sa" {
  description = "Whether the cloud service account for the UI should be created"
  type        = bool
  default     = true
}

variable "jx2" {
  description = "Is a Jenkins X 2 install"
  type        = bool
  default     = true
}

variable "jx_git_url" {
  description = "URL for the Jenins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_username" {
  description = "Bot username used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_token" {
  description = "Bot token used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_git_operator_version" {
  description = "The jx-git-operator helm chart version"
  type        = string
  default     = "0.0.192"
}

variable "kuberhealthy" {
  description = "Enable Kuberhealthy helm installation"
  type        = bool
  default     = true
}

variable "content" {
  description = "Interpolated jx-requirements.yml"
  type        = string
  default     = ""
}
