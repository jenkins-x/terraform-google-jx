// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "velero_sa_email" {
  type        = string
  description = "Velero service acocunt email"
}

// ----------------------------------------------------------------------------
// Optional Variables
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
