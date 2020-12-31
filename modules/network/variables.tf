variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "gcp_project" {
  description = "The name of the GCP project"
  type        = string
}

variable "cluster_location" {
  description = "The location (region or zone) in which the cluster master will be created. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region"
  type        = string
}

variable "network" {
  description = "VPC to be used for setting-up private network"
  type        = string
}
