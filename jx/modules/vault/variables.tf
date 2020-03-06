// ----------------------------------------------------
// Required Variables
// ----------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to create all resources"
  type = string
}

variable "zone" {
  description = "The GCloud zone in which to create the resources"
  type = string
}

variable "cluster_name" {
  description = "Name of the K8s cluster"
  type = string
}

variable "cluster_id" {
  description = "A random generated to uniqly name cluster resources"
  type = string
}

variable "jenkins_x_namespace" {
  description = "K8s namespace to install Jenkins X in"
  type = string
}
