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

// ----------------------------------------------------
// Optional Variables
// ----------------------------------------------------
variable "storage_sa_suffix" {
  description = "The string to append to the storage service-account name"
  default     = "st"
}

variable "velero_sa_suffix" {
  description = "The string to append to the velero service-account name"
  default     = "velero"
}

variable "jx_namespace" {
  default = "jx"
}

