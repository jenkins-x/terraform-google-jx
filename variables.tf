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
variable "version_stream_ref" {
  default = "master"
}

variable "version_stream_url" {
  default = "https://github.com/jenkins-x/jenkins-x-versions.git"
}

variable "webhook" {
  default = "prow"
}
