terraform {
  backend "gcs" {
    bucket = "<my-terraform-state-bucket>"
    # arbitrary prefix/directory within the bucket
    prefix = "jx"
  }
}

module "jx" {
  source = "jenkins-x/jx/google"

  gcp_project = "<my-gcp-project-id>"
}
