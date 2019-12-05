output "externaldns_sa" {
  value = "${google_service_account.externaldns_sa.account_id}"
}
