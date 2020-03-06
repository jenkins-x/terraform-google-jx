// ----------------------------------------------------
// Required Variables
// ----------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to create all resources"
  type = string
}

variable "cluster_name" {
  description = "Name of the K8s cluster"
  type = string
}

variable "dns_enabled" {
  description = "Toggle on whether the dns module is enabled"
  type = bool
}

variable "parent_domain" {
  description = "The parent domain to be allocated to the cluster"
  type        = string
}
