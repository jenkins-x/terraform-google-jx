terraform {
  required_version = "~> 0.12.0"
}

module "jx" {
  source = "./jx"

  gcp_project                 = var.gcp_project
  zone                        = var.zone
  cluster_name                = var.cluster_name
  parent_domain               = var.parent_domain
  force_destroy               = var.force_destroy
  tls_email                   = var.tls_email
  velero_schedule             = var.velero_schedule
  velero_ttl                  = var.velero_ttl
  node_machine_type           = var.node_machine_type
  min_node_count              = var.min_node_count
  max_node_count              = var.max_node_count
  node_disk_size              = var.node_disk_size
  git_owner_requirement_repos = var.git_owner_requirement_repos
  dev_env_approvers           = var.dev_env_approvers
  webhook                     = var.webhook
  version_stream_url          = var.version_stream_url
  version_stream_ref          = var.version_stream_ref
}
