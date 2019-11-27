resource "google_monitoring_uptime_check_config" "hook" {
  display_name = "[JX] hook-${var.jx_namespace}.${var.gcp_project}.${var.parent_domain}"
  timeout      = "10s"
  project      = "${var.monitoring_project_id}"
  period       = "60s"

  http_check {
    mask_headers = false
    path         = "/"
    port         = "443"
    use_ssl      = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = "hook-${var.jx_namespace}.${var.gcp_project}.${var.parent_domain}"
      project_id = "${var.monitoring_project_id}"
    }
  }
}

resource "google_monitoring_uptime_check_config" "deck" {
  display_name = "[JX] deck-${var.jx_namespace}.${var.gcp_project}.${var.parent_domain}"
  timeout = "10s"
  project = "${var.monitoring_project_id}"
  period = "60s"

  http_check {
    mask_headers  = false
    path = "/"
    port = "443"
    use_ssl = true
    auth_info {
      username = "admin"
      password = "${var.admin_password}"
    }
  }

  monitored_resource {
    type   = "uptime_url"
    labels = {
      host = "deck-${var.jx_namespace}.${var.gcp_project}.${var.parent_domain}"
      project_id = "${var.monitoring_project_id}"
    }
  }
} 

