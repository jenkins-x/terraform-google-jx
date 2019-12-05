terraform {
  required_version = ">= 0.12.0"
}

module "jx" {
  source = "./jx"

  gcp_project = "terraform-test"
  region = "europe-west1"
  zone = "europe-west1-b"
  cluster_name  = "test-cluster"
  user_email = "test@test.com"
  parent_domain = ""
}
