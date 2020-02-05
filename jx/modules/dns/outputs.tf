output "externaldns_sa" {
  value = "${google_service_account.externaldns_sa.account_id}"
}

output "externaldns_ns" {
  value = google_dns_managed_zone.externaldns_managed_zone.*.name_servers
}
