terraform {
  backend "gcs" {
    bucket = "<my-terraform-state-bucket>"
    # You can generate a key with 'openssl rand -base64 32'
    # You can set the key explicitly or via exporting GOOGLE_ENCRYPTION_KEY
    # Make sure to safely store the key, since your Terraform state cannot be recovered if the key is lost
    encryption_key = "<my-encryptionkey>"
  }
}

module "jx" {
  source = "jenkins-x/jx/google"

  gcp_project = "<my-gcp-project-id>"
}
