
variable "gcp_project" {
  description = "The name of the GCP project"
  type        = string
}
variable "cluster_id" {
  description = "A random generated to uniqly name cluster resources"
  type        = string
}
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}
variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
}
// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
// storage
variable "bucket_location" {
  description = "Bucket location for storage"
  type        = string
  default     = "US"
}

variable "enable_log_storage" {
  description = "Flag to enable or disable storage of build logs in a cloud bucket"
  type        = bool
  default     = true
}

variable "enable_report_storage" {
  description = "Flag to enable or disable storage of build reports in a cloud bucket"
  type        = bool
  default     = true
}

variable "enable_repository_storage" {
  description = "Flag to enable or disable storage of artifacts in a cloud bucket"
  type        = bool
  default     = true
}
variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed"
  type        = bool
  default     = false
}

// service accounts
variable "create_ui_sa" {
  description = "Whether the cloud service account for the UI should be created"
  type        = bool
  default     = true
}

variable "jx2" {
  description = "Is a Jenkins X 2 install"
  type        = bool
  default     = true
}

variable "jx_git_url" {
  description = "URL for the Jenins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_username" {
  description = "Bot username used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_token" {
  description = "Bot token used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_git_operator_version" {
  description = "The jx-git-operator helm chart version"
  type        = string
  default     = "0.0.192"
}

variable "kuberhealthy" {
  description = "Enable Kuberhealthy helm installation"
  type        = bool
  default     = true
}

variable "content" {
  description = "Interpolated jx-requirements.yml"
  type        = string
  default     = ""
}
