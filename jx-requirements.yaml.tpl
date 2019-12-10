cluster:
  clusterName: "${cluster_name}"
  environmentGitOwner: ""
  project: "${gcp_project}"
  provider: gke
  zone: "${zone}"
gitops: true
environments:
- key: dev
- key: staging
- key: production
ingress:
  domain: ""
  externalDNS: true
  tls:
    email: ""
    enabled: true
    production: true
kaniko: true
secretStorage: vault
storage:
  backup:
    enabled: true
    url: ${backup_bucket}
  logs:
    enabled: true
    url: ${lts_bucket}
  reports:
    enabled: false
    url: ""
  repository:
    enabled: false
    url: ""
vault:
  bucket: ${vault_bucket}
  key: ${vault_key}
  keyring: ${vault_keyring}
  name: ${vault_name}
  serviceAccount: ${vault_sa}
versionStream:
  ref: "master"
  url: https://github.com/jenkins-x/jenkins-x-versions.git
webhook: prow
