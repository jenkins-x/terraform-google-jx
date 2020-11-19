output "externaldns_ns" {
  description = "ExternalDNS nameservers"
  value       = google_dns_managed_zone.externaldns_managed_zone_with_sub.*.name_servers
}

output "externaldns_dns_name" {
  description = "ExternalDNS name"
  value       = google_dns_managed_zone.externaldns_managed_zone_with_sub.*.dns_name
}
