autoUpdate:
  enabled: false
  schedule: ""
cluster:
  clusterName: "${cluster_name}"
  devEnvApprovers: %{ if length(dev_env_approvers) == 0 }[]%{ endif }
%{ for name in dev_env_approvers }  - ${name}
%{ endfor }
  environmentGitOwner: "${git_owner_requirement_repos}"
  project: "${gcp_project}"
  provider: gke
  zone: "${zone}"
gitops: true
environments:
- key: dev
- key: staging
- key: production
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
kaniko: true
kuberhealthy: ${kuberhealthy}
storage:
  backup:
    enabled: ${enable_backup}
%{ if enable_backup }
    url: ${backup_bucket_url}
%{ endif }
  logs:
    enabled: %{ if log_storage_url != "" }true%{ else }false%{ endif }
    url: ${log_storage_url}
  reports:
    enabled: %{ if report_storage_url != "" }true%{ else }false%{ endif }
    url: ${report_storage_url}
  repository:
    enabled: %{ if repository_storage_url != "" }true%{ else }false%{ endif }
    url: ${repository_storage_url}
secretStorage: vault
terraformVault: ${vault_installed}
vault:
%{ if external_vault }
  url: ${vault_url}
%{ else }
  name: ${vault_name}
  bucket: ${vault_bucket}
  key: ${vault_key}
  keyring: ${vault_keyring}
%{ endif }
  serviceAccount: ${vault_sa}
%{ if enable_backup }
velero:
  namespace: ${velero_namespace}
  schedule: "${velero_schedule}"
  serviceAccount: ${velero_sa}
  ttl: "${velero_ttl}"
%{ endif }
versionStream:
  ref: ${version_stream_ref}
  url: ${version_stream_url}
webhook: "${webhook}"
