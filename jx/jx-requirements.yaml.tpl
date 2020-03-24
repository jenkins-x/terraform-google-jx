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
%{ if domain_enabled }ingress:
  domain: "${parent_domain}"
  externalDNS: true
  tls:
    email: "${tls_email}"
    enabled: ${domain_enabled}
    production: true%{ endif }    
kaniko: true
storage:
  backup:
    enabled: %{ if backup_bucket_url != "" }true%{ else }false%{ endif }
    url: ${backup_bucket_url}
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
vault:
  name: ${vault_name}
  bucket: ${vault_bucket}
  key: ${vault_key}
  keyring: ${vault_keyring}
  serviceAccount: ${vault_sa}
velero:
  namespace: ${velero_namespace}
  schedule: "${velero_schedule}"
  serviceAccount: ${velero_sa}
  ttl: "${velero_ttl}"  
versionStream:
  ref: ${version_stream_ref}
  url: ${version_stream_url}
webhook: "${webhook}"
