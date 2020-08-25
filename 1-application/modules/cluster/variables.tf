// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------

variable "jenkins_x_namespace" {
  description = "Kubernetes namespace to install Jenkins X in"
  type        = string
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

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------

// service accounts
variable "create_ui_sa" {
  description = "Whether the service accounts for the UI should be created"
  type        = bool
  default     = false
}

variable "jx2" {
  description = "Is a Jenkins X 2 install"
  type        = bool
  default     = true
}

variable "content" {
  description = "Interpolated jx-requirements.yml"
  type        = string
  default     = ""
}
