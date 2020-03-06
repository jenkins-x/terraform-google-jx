// ----------------------------------------------------
// Required Variables
// ----------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project"
  type = string
}

variable "zone" {
  description = "Zone within specified region"
  type = string
}

variable "cluster_name" {
  description = "Name of the K8s cluster"
  type = string
}

// ----------------------------------------------------
// Optional Variables
// ----------------------------------------------------
variable "jenkins_x_namespace" {
  description = "K8s namespace to install Jenkins X in"
  type        = string
  default     = "jx"
}

// storage
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

variable "parent_domain" {
  description = "The parent domain to be allocated to the cluster"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed"
  type        = bool
  default     = true
}

// cluster configuration
variable "node_machine_type" {
  description = "Node type for the K8s cluster"
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

variable "node_preemptible" {
  description = "Use preemptible nodes"
  type        = bool
  default     = false
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
