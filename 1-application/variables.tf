// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "gcp_project" {
  description = "The name of the GCP project to use"
  type        = string
}

variable "access_token" {
  type        = string
  description = "Kubernetes cluster access token"
}
// ----------------------------------------------------------------------------
// Service accounts
variable "build_controller_sa_email" {
  type        = string
  description = "The email of builder controller service account"
}

variable "kaniko_sa_email" {
  type        = string
  description = "The email of Kaniko service account"
}

variable "tekton_sa_email" {
  type        = string
  description = "The email of Kaniko service account"
}

variable "jxui_sa_email" {
  type        = string
  description = "The email of Kaniko service account"
}

variable "dns_sa_email" {
  type        = string
  description = "DNS service account email"
}

// ---------
variable "backup_bucket_url" {
  type        = string
  description = "Backup bucket url"
}

variable "backup_velero_sa" {
  type        = string
  description = "Valero service account"
}

variable "backup_velero_sa_email" {
  type        = string
  description = "Valero service account email"
}

variable "vault_sa" {
  type        = string
  description = "Vault service account"
}

variable "vault_sa_email" {
  type        = string
  description = "Vault service account email"
}

variable "vault_name" {
  type        = string
  description = "Vault name"
}

variable "vault_keyring" {
  type        = string
  description = "Vault keyring"
}

variable "vault_key" {
  type        = string
  description = "Vault key"
}

variable "vault_bucket_name" {
  type        = string
  description = "Vault bucket name"
}

variable "repository_storage_url" {
  type        = string
  description = "Repository storage url"
}

variable "report_storage_url" {
  type        = string
  description = "Report storage url"
}

variable "log_storage_url" {
  type        = string
  description = "Log storage url"
}

variable "cluster_ca_certificate" {
  type        = string
  description = "Cluster CA certificate"
}

variable "cluster_endpoint" {
  type        = string
  description = "Cluster endpoint"
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the Kubernetes cluster to create"
  type        = string
  default     = ""
}

variable "zone" {
  description = "Zone in which to create the cluster (deprecated, use cluster_location instead)"
  type        = string
  default     = ""
}

variable "cluster_location" {
  description = "The location (region or zone) in which the cluster master will be created. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region"
  type        = string
  default     = "us-central1-a"
}

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
  default     = "jx"
}

variable "parent_domain" {
  description = "The parent domain to be allocated to the cluster"
  type        = string
  default     = ""
}

variable "tls_email" {
  description = "Email used by Let's Encrypt. Required for TLS when parent_domain is specified"
  type        = string
  default     = ""
}

variable "create_ui_sa" {
  description = "Whether the service accounts for the UI should be created"
  type        = bool
  default     = false
}

// ----------------------------------------------------------------------------
// Vault
// ----------------------------------------------------------------------------
variable "vault_url" {
  description = "URL to an external Vault instance in case Jenkins X shall not create its own system Vault"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// Velero/backup
// ----------------------------------------------------------------------------
variable "enable_backup" {
  description = "Whether or not Velero backups should be enabled"
  type        = bool
  default     = false
}

variable "velero_namespace" {
  description = "Kubernetes namespace for Velero"
  type        = string
  default     = "velero"
}

variable "velero_schedule" {
  description = "The Velero backup schedule in cron notation to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml))"
  type        = string
  default     = "0 * * * *"
}

variable "velero_ttl" {
  description = "The the lifetime of a velero backup to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup))"
  type        = string
  default     = "720h0m0s"
}

// ----------------------------------------------------------------------------
// jx-requirements.yml specific variables only used for template rendering
// ----------------------------------------------------------------------------
variable "git_owner_requirement_repos" {
  description = "The git id of the owner for the requirement repositories"
  type        = string
  default     = ""
}

variable "dev_env_approvers" {
  description = "List of git users allowed to approve pull request for dev enviornment repository"
  type        = list(string)
  default     = []
}

variable "lets_encrypt_production" {
  description = "Flag to determine wether or not to use the Let's Encrypt production server."
  type        = bool
  default     = true
}

variable "webhook" {
  description = "Jenkins X webhook handler for git provider"
  type        = string
  default     = "lighthouse"
}

variable "version_stream_url" {
  description = "The URL for the version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/"
  type        = string
  default     = "https://github.com/jenkins-x/jenkins-x-versions.git"
}

variable "version_stream_ref" {
  description = "The git ref for version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/"
  type        = string
  default     = "master"
}

variable "jx2" {
  description = "Is a Jenkins X 2 install"
  type        = bool
  default     = true
}
