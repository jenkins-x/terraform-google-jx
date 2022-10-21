output "argocd_sa" {
  value = google_service_account.argocd_sa
}

output "argocd_sa_email" {
  value = google_service_account.argocd_sa.email
}

output "argocd_sa_name" {
  value = google_service_account.argocd_sa.name
}
