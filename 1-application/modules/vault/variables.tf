// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
}

variable "vault_sa_email" {
  type        = string
  description = "Vault service account emails"
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "external_vault" {
  description = "Whether or not Jenkins X creates and manages the Vault instance. If set to true a external Vault URL needs to be provided"
  type        = bool
  default     = false
}

variable "jx2" {
  description = "Is a Jenkins X 2 install"
  type        = bool
  default     = true
}
