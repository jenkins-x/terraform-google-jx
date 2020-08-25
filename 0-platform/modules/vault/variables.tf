// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to create all resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "cluster_id" {
  description = "A random generated to uniqly name cluster resources"
  type        = string
}

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "external_vault" {
  description = "Whether or not Jenkins X creates and manages the Vault instance. If set to true a external Vault URL needs to be provided"
  type        = bool
  default     = false
}

variable "bucket_location" {
  description = "Bucket location for storage"
  type        = string
  default     = "US"
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed"
  type        = bool
  default     = false
}

variable "jx2" {
  description = "Is a Jenkins X 2 install"
  type        = bool
  default     = true
}
