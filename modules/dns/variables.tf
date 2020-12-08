// ----------------------------------------------------
// Required Variables
// ----------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to create all resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "apex_domain" {
  description = "The apex domain to be allocated to the cluster"
  type        = string
}

variable "apex_domain_gcp_project" {
  description = "The GCP project the apex domain is managed by, used to write recordsets for a subdomain if set.  Defaults to current project."
  type        = string
  default     = ""
}

variable "apex_domain_integration_enabled" {
  description = "If parent / apex domain is managed in the same "
  type        = bool
  default     = true
}

variable "subdomain" {
  description = "Optional sub domain for the installation"
  type        = string
}

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "cert-manager-namespace" {
  description = "Kubernetes namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "jx2" {
  description = "Is a Jenkins X 2 install"
  type        = bool
  default     = true
}
