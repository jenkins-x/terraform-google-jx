// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to create all resources"
  type = string
}

variable "zone" {
  description = "The GCloud zone in which to create the resources"
  type = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type = string
}

variable "cluster_id" {
  description = "A random generated to uniqly name cluster resources"
  type = string
}

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type = string
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed"
  type        = bool
  default     = false
}
