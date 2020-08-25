# output "externaldns_sa" {
#   description = "GKE service account name for ExternalDNS"
#   value       = google_service_account.externaldns_sa.account_id
# }

# output "externaldns_ns" {
#   description = "ExternalDNS nameservers"
#   value       = google_dns_managed_zone.externaldns_managed_zone.*.name_servers
# }

# output "externaldns_dns_name" {
#   description = "ExternalDNS name"
#   value       = google_dns_managed_zone.externaldns_managed_zone.*.dns_name
# }

output "dns_sa_email" {
  value = google_service_account.dns_sa.email
}