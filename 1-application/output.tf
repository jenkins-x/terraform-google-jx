output "gcp_project" {
  description = "The GCP project in which the resources got created"
  value       = var.gcp_project
}

output "cluster_location" {
  description = "The location of the created Kubernetes cluster"
  value       = var.cluster_location
}

output "cluster_name" {
  description = "The name of the created Kubernetes cluster"
  value       = local.cluster_name
}

output "jx_requirements" {
  description = "The jx-requirements rendered output"
  value       = local.content
}

output "connect" {
  description = "The cluster connection string to use once Terraform apply finishes"
  value       = "gcloud container clusters get-credentials ${local.cluster_name} --zone ${var.cluster_location} --project ${var.gcp_project} && jx ns ${var.jenkins_x_namespace} -q"
}
