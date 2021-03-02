cluster:
  clusterName: "${cluster_name}"
  project: "${gcp_project}"
  provider: gke
  zone: "${zone}"
ingress:
%{ if subdomain != "" }
  domain: "${subdomain}.${apex_domain}"
  externalDNS: ${domain_enabled}
%{ else }
  domain: "${apex_domain}"
  externalDNS: ${domain_enabled}
%{ endif }
  tls:
    email: "${tls_email}"
    enabled: ${domain_enabled}
    production: ${lets_encrypt_production}
kuberhealthy: ${kuberhealthy}
storage:
%{ if enable_backup }
  - name: backup
    enabled: true
    url: "${backup_bucket_url}"
%{ endif }
%{ if log_storage_url != "" }
  - name: logs
    enabled: true
    url: "${log_storage_url}"
%{ endif }
%{ if report_storage_url != "" }
  - name: reports
    enabled: true
    url: "${report_storage_url}"
%{ endif }
%{ if repository_storage_url != "" }
  - name: repository
    enabled: true
    url: "${repository_storage_url}"
%{ endif }
terraformVault: ${vault_installed}
vault:
%{ if external_vault }
  url: "${vault_url}"
%{ else }
  name: "${vault_name}"
  bucket: "${vault_bucket}"
  key: "${vault_key}"
  keyring: "${vault_keyring}"
%{ endif }
  serviceAccount: "${vault_sa}"
webhook: "${webhook}"
