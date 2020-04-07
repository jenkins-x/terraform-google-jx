// ----------------------------------------------------
// Required Variables
// ----------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to create all resources"
  type = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type = string
}

variable "parent_domain" {
  description = "The parent domain to be allocated to the cluster"
  type        = string
}

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type = string
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "cert-manager-namespace" {
  description = "Kubernetes namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}