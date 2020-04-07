// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to use"
  type        = string
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the Kubernetes cluster to create"
  type        = string
  default     = ""
}

variable "zone" {
  description = "Zone in which to create the cluster"
  type        = string
  default     = "us-central1-a"
}

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
  default     = "jx"
}

variable "velero_namespace" {
  description = "Kubernetes namespace for Velero"
  type        = string
  default     = "velero"
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed"
  type        = bool
  default     = false
}

variable "parent_domain" {
  description = "The parent domain to be allocated to the cluster"
  type        = string
  default     = ""
}

variable "tls_email" {
  description = "Email used by Let's Encrypt. Required for TLS when parent_domain is specified."
  type        = string
  default     = ""
}

variable "velero_schedule" {
  description = "The Velero backup schedule in cron notation to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml))"
  type        = string
  default     = "0 * * * *"
}

variable "velero_ttl" {
  description = "The the lifetime of a velero backup to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup))"
  type        = string
  default     = "720h0m0s"
}

// ----------------------------------------------------------------------------
// cluster configuration
// ----------------------------------------------------------------------------
variable "node_machine_type" {
  description = "Node type for the Kubernetes cluster"
  type        = string
  default     = "n1-standard-2"
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

variable "node_disk_size" {
  description = "Node disk size in GB"
  type        = string
  default     = "100"
}

variable "resource_labels" {
  description = "Set of labels to be applied to the cluster"
  type        = map
  default     = {}
}

// ----------------------------------------------------------------------------
// jx-requirements.yml specific variables only used for template rendering
// ----------------------------------------------------------------------------
variable "git_owner_requirement_repos" {
  description = "The git id of the owner for the requirement repositories"
  type        = string
  default     = ""
}

variable "dev_env_approvers" {
  description = "List of git users allowed to approve pull request for dev enviornment repository"
  type        = list(string)
  default     = []
}

variable "webhook" {
  description = "Jenkins X webhook handler for git provider"
  type        = string
  default     = "prow"
}

variable "version_stream_url" {
  description = "The URL for the version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/"
  type        = string
  default     = "https://github.com/jenkins-x/jenkins-x-versions.git"
}

variable "version_stream_ref" {
  description = "The git ref for version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/"
  type        = string
  default     = "master"
}
