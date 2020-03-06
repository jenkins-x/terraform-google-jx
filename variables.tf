// ----------------------------------------------------
// Required Variables
// ----------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to use"
  type        = string
}

variable "cluster_name" {
  description = "Name of the K8s cluster to create"
  type        = string
}

variable "zone" {
  description = "Zone in which to create the cluster"
  type        = string
}

// ----------------------------------------------------
// Optional Variables
// ----------------------------------------------------
variable "git_owner_requirement_repos" {
  description = "The git id of the owner for the requirement repositories"
  type        = string
  default     = ""
}

variable "dev_env_approvers" {
  description = "List of git users allowed to approve pull request for dev enviornment repository"
  default     = []
}

variable "parent_domain" {
  description = "The parent domain to be allocated to the cluster"
  type        = string
  default     = ""
}

variable "velero_namespace" {
  default = "velero"
}

variable "velero_schedule" {
  description = "The parent domain to be allocated to the cluster - check https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml for defaults"
  default     = "0 * * * *"
}

variable "velero_ttl" {
  description = "The time allocated that defines the lifetime of a velero backup - check https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml for defaults"
  default     = "720h0m0s"
}

variable "version_stream_ref" {
  default = "master"
}

variable "version_stream_url" {
  default = "https://github.com/jenkins-x/jenkins-x-versions.git"
}


