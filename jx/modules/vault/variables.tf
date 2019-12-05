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

variable "vault_sa_suffix" {
  description = "The string to append to the vault service-account name"
  default     = "vt"
}

variable "jx_namespace" {
  default = "jx"
}

