output "externaldns_ns" {
  description = "ExternalDNS nameservers"
  value       = google_dns_managed_zone.externaldns_managed_zone.*.name_servers
}

output "externaldns_dns_name" {
  description = "ExternalDNS name"
  value       = google_dns_managed_zone.externaldns_managed_zone.*.dns_name
}
