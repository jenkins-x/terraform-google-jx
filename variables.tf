// ----------------------------------------------------
// Required Variables
// ----------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to create all resources"
}

variable "zone" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "cluster_name" {
  description = "Name of the K8s cluster"
}

variable "organisation" {
  description = "Organisation name for the cluster"
  default     = "cloudbees-poc"
}

// ----------------------------------------------------
// Optional Variables
// ----------------------------------------------------
variable "cluster_size" {
  type        = "string"
  description = "small|medium|large"
  default     = "small"
}

variable "min_node_counts" {
  type = "map"
  default = {
    "small"  = "5"
    "medium" = "7"
    "large"  = "10"
  }
}

variable "max_node_counts" {
  type = "map"
  default = {
    "small"  = "10"
    "medium" = "20"
    "large"  = "30"
  }
}

variable "node_machine_types" {
  type = "map"
  default = {
    "small"  = "n1-standard-2"
    "medium" = "n1-standard-4"
    "large"  = "n1-standard-8"
  }
}

variable "node_preemptible" {
  description = "Use preemptible nodes"
  default     = "false"
}

variable "node_disk_size" {
  description = "Node disk size in GB"
  default     = "100"
}

variable "enable_kubernetes_alpha" {
  default = "false"
}

variable "enable_legacy_abac" {
  default = "true"
}

variable "auto_repair" {
  default = "false"
}

variable "auto_upgrade" {
  default = "false"
}

variable "created_by" {
  description = "The user that created the cluster"
  default     = "Unknown"
}

variable "created_timestamp" {
  description = "The timestamp this cluster was created"
  default     = "Unknown"
}

variable "monitoring_service" {
  description = "The monitoring service to use. Can be monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none"
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "logging_service" {
  description = "The logging service to use. Can be logging.googleapis.com, logging.googleapis.com/kubernetes (beta) and none"
  default     = "logging.googleapis.com/kubernetes"
}

variable "admin_password" {
  description = "The admin password for the cluster"
  default     = "Admin_1234!"
}

variable "kaniko_sa_suffix" {
  description = "The string to append to the kaniko service-account name"
  default     = "ko"
}

variable "vault_sa_suffix" {
  description = "The string to append to the vault service-account name"
  default     = "vt"
}

variable "externaldns_sa_suffix" {
  description = "The string to append to the external-dns service-account name"
  default     = "dn"
}

variable "jxboot_sa_suffix" {
  description = "The string to append to the jx-boot service-account name"
  default     = "jb"
}

variable "storage_sa_suffix" {
  description = "The string to append to the storage service-account name"
  default     = "st"
}

variable "tekton_sa_suffix" {
  description = "The string to append to the tekton service-account name"
  default     = "tk"
}

variable "velero_sa_suffix" {
  description = "The string to append to the velero service-account name"
  default     = "velero"
}

variable "test_cluster_label" {
  description = "Describes whether the cluster is going to be used for BDD tests"
}

variable "boot_git_url" {
  description = "The URL of the Boot config"
}

variable "boot_git_ref" {
  description = "The Git Ref of the Boot config"
}

variable "ingress_tls_production" {
  description = "Whether to use production TLS"
}

variable "user_email" {
  description = "Email address of the user who requested the creation of the instance"
}

variable "versions_git_url" {
  description = "The URL of the Versions Stream"
}

variable "versions_git_ref" {
  description = "The Git Ref of the Versions Stream"
}

variable "monitoring_project_id" {
  description = "The project to send stackdriver alerts to"
  default     = "jxaas-dev-monitoring"
}

variable "parent_domain" {
  description = "The parent domain which the instance will be provisioned with - this is issued by the tenant-service"
}

variable "repository_kind" {
  description = "Select which artifact repository to install"
}

variable "jx_namespace" {
  default = "jx"
}


