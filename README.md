# EXPERIMENTAL terraform-google-jx

![Build Status](https://img.shields.io/endpoint?url=https%3A%2F%2Fstatusbadge-jx.jenkins-x.live%2Fterraform-google-jx)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)

## Basic instructions

### Terraform Requirements

This module requires terraform v0.12 and above.

```
terraform {
  required_version = ">= 0.12.0"
}
```

The module can be configured as follows:

```
module "jx" {
  source = "./jx"

  gcp_project   = var.gcp_project
  region        = var.region
  zone          = var.zone
  cluster_name  = var.cluster_name
  parent_domain = "test.com"
}
```

It is possible to template out the jx-requirements.yaml so that `jx boot` can be run directly
against the generated file.

```
resource "local_file" "jx-requirements" {
  content = templatefile("${path.module}/jx-requirements.yaml.tpl", {
    cluster_name  = module.jx.cluster_name
    gcp_project   = module.jx.gcp_project
    zone          = module.jx.zone
    lts_bucket    = module.jx.lts_bucket_url
    backup_bucket = module.jx.backup_bucket_url
    vault_bucket  = module.jx.vault_bucket_name
    vault_key     = module.jx.vault_key
    vault_keyring = module.jx.vault_keyring
    vault_name    = module.jx.vault_name
    vault_sa      = module.jx.vault_sa
    // from variables
    version_stream_ref = var.version_stream_ref
    version_stream_url = var.version_stream_url
    webhook            = var.webhook
  })
  filename = "${path.module}/jx-requirements.yaml"
}
```

```
jx boot --requirements jx-requirements.yaml
```

# Storing State

Its recommended to store the terraform state in a remote bucket to avoid persisting this to local disk.

TODO
