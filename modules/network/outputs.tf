output "network" {
  value = try(google_compute_network.network[0].self_link, var.network)
}

output "subnetwork" {
  value = google_compute_subnetwork.subnetwork.self_link
}

output "master_range" {
  value = local.master_range
}

output "pod_range_name" {
  value = local.pod_range_name
}

output "svc_range_name" {
  value = local.svc_range_name
}

output "bastion_name" {
  value = google_compute_instance.bastion.name
}

output "bastion_zone" {
  value = google_compute_instance.bastion.zone
}

output "bastion_link" {
  value = google_compute_instance.bastion.self_link
}
