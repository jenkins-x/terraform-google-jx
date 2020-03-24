# Jenkins X GKE Module
<a id="markdown-jenkins-x-gke-module" name="jenkins-x-gke-module"></a>

![Build Status](https://img.shields.io/endpoint?url=https%3A%2F%2Fstatusbadge-jx.jenkins-x.live%2Fterraform-google-jx)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)

This repo contains a [Terraform](https://www.terraform.io/) Module for provisioning a Kubernetes cluster for [Jenkins X](https://jenkins-x.io/) on [Google Cloud](https://cloud.google.com/).

<!-- TOC depthfrom:2 -->

- [What is a Terraform Module](#what-is-a-terraform-module)
- [How do you use this Module](#how-do-you-use-this-module)
    - [Prerequisites](#prerequisites)
    - [Cluster provisioning](#cluster-provisioning)
        - [Inputs](#inputs)
        - [Outputs](#outputs)
    - [Running `jx boot`](#running-jx-boot)
    - [Using a custom domain](#using-a-custom-domain)
- [How do I contribute](#how-do-i-contribute)

<!-- /TOC -->

## What is a Terraform Module
<a id="markdown-what-is-a-terraform-module" name="what-is-a-terraform-module"></a>

A Terraform Module refers to a self-contained package of Terraform configurations that are managed as a group.
For more information around Modules refer to the Terraform [documentation](https://www.terraform.io/docs/modules/index.html).

## How do you use this Module
<a id="markdown-how-do-you-use-this-module" name="how-do-you-use-this-module"></a>

### Prerequisites
<a id="markdown-prerequisites" name="prerequisites"></a>

To make use of this Module, you need a Google Cloud project.
Instructions on how to do this can be found [here](https://cloud.google.com/deployment-manager/docs/step-by-step-guide/installation-and-setup).
You need your Google Cloud project id as an input variable for using this Module.

You also need to install the Cloud SDK, in particular `gcloud`.
You find instructions on how to install and authenticate in the documentation mentioned above.

Once you have `gcloud` installed, you need to create [Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login) by running:

```bash
gcloud auth application-default login
```

Last but not least, ensure you have the following binaries installed:

- `gcloud`
- `kubectl` ~> 1.14.0
    - `kubectl` comes bundled with the Cloud SDK
- `terraform` ~> 0.12.0
    - Terraform installation instruction can be found [here](https://learn.hashicorp.com/terraform/getting-started/install)

### Cluster provisioning
<a id="markdown-cluster-provisioning" name="cluster-provisioning"></a>

A default Jenkins X ready cluster can be provisioned by creating a file _main.tf_ in an empty directory with the following content:

```terraform
module "jx" {
  source  = "jenkins-x/jx/google"

  gcp_project = "<my-gcp-project-id>"
}
```

You can then apply this Terraform configuration via:

```bash
terraform init
terraform apply
```

This creates a cluster within the specified Google Cloud project with all names and settings defaulted.
The default cluster name is _jenkins-x_.
On completion of `terraform apply` there will also be a _jx-requirements.yaml_ in the working directory which can be used as input to `jx boot`.
Refer to [Running `jx boot`](#running-jx-boot) for more information.
Per default, no custom domain is used.
Instead DNS resolution is via [nip.io](https://nip.io/).
For more information on how to configure and use a custom domain, refer to [Using a custom domain](#using-a-custom-domain).

If you just want to experiment with Jenkins X, you can set `force_destroy` to `true`.
This allows you to remove all generated resources when running `terraform destroy`, including any generated buckets with their content.

The following two paragraphs provide the full list of configuration and output variables of this Terraform Module.

#### Inputs
<a id="markdown-inputs" name="inputs"></a>

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| cluster\_name | Name of the K8s cluster to create | `string` | `"jenkins-x"` | no |
| dev\_env\_approvers | List of git users allowed to approve pull request for dev enviornment repository | `list(string)` | `[]` | no |
| force\_destroy | Flag to determine whether storage buckets get forcefully destroyed | `bool` | `false` | no |
| gcp\_project | The name of the GCP project to use | `string` | n/a | yes |
| git\_owner\_requirement\_repos | The git id of the owner for the requirement repositories | `string` | `""` | no |
| max\_node\_count | Maximum number of cluster nodes | `number` | `5` | no |
| min\_node\_count | Minimum number of cluster nodes | `number` | `3` | no |
| node\_disk\_size | Node disk size in GB | `string` | `"100"` | no |
| node\_machine\_type | Node type for the K8s cluster | `string` | `"n1-standard-2"` | no |
| parent\_domain | The parent domain to be allocated to the cluster | `string` | `""` | no |
| tls\_email | Email used by Let's Encrypt. Required for TLS when parent\_domain is specified. | `string` | `""` | no |
| velero\_schedule | The Velero backup schedule in cron notation to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml)) | `string` | `"0 * * * *"` | no |
| velero\_ttl | The the lifetime of a velero backup to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup)) | `string` | `"720h0m0s"` | no |
| version\_stream\_ref | The git ref for version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/ | `string` | `"master"` | no |
| version\_stream\_url | The URL for the version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/ | `string` | `"https://github.com/jenkins-x/jenkins-x-versions.git"` | no |
| webhook | Jenkins X webhook handler for git provider | `string` | `"prow"` | no |
| zone | Zone in which to create the cluster | `string` | `"us-central1-a"` | no |

#### Outputs
<a id="markdown-outputs" name="outputs"></a>

| Name | Description |
|------|-------------|
| backup\_bucket\_url | The URL to the bucket for backup storage |
| cluster\_name | The name of the created K8s cluster |
| gcp\_project | The GCP project in which the resources got created in |
| log\_storage\_url | The URL to the bucket for log storage |
| report\_storage\_url | The URL to the bucket for report storage |
| repository\_storage\_url | The URL to the bucket for artefact storage |
| vault\_bucket\_url | The URL to the bucket for secret storage |
| zone | The zone of the created K8s cluster |

### Running `jx boot`
<a id="markdown-running-jx-boot" name="running-jx-boot"></a>

As an output of applying this Terraform Module a _jx-requirements.yaml_ file is generated in the current directory.
This file can be used as input to [Jenkins X Boot](https://jenkins-x.io/docs/getting-started/setup/boot/) which is responsible for installing all the required Jenkins X components into the cluster created by this Module.

Copy the generated _jx-requirements.yaml_ into an empty directory, change into this directory and execute:

```bash
jx boot --requirements jx-requirements.yaml
```

You have to provide some more required configuration via interactive prompts.
The number of prompts depends on how much you have [pre-configured](#inputs) via your Terraform variables.

### Using a custom domain
<a id="markdown-using-a-custom-domain" name="using-a-custom-domain"></a>

If you want to use a custom domain with your Jenkins X installation, you need to provide values for the [variables](#inputs) _parent_domain_ and _tls_email_.
_parent_domain_ is the fully qualified domain name you want to use and _tls_email_ is the email you want to use for issuing Let's Encrypt TLS certificates.

Before you run the Terraform configuration, you also need to create a [Cloud DNS managed zone](https://cloud.google.com/dns/zones), with the DNS name in the managed zone matching your custom domain name, for example in the case of _example.jenkins-x.rocks_ as domain:

![Creating a Managed Zone](./images/create_managed_zone.png)

When creating the managed zone, a set of DNS servers get created which you need to specify in the DNS settings of your DNS registrar.

![DNS settings of Managed Zone](./images/managed_zone_details.png)

It is essential that before you run `jx boot`, your DNS servers settings are propagated, and your domain resolves.
You can use [DNS checker](https://dnschecker.org/) to check whether your domain settings have propagated.

When a custom domain is provided, Jenkins X uses [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) together with [cert-manager](https://github.com/jetstack/cert-manager) to create A record entries in your managed zone for the various exposed applications.

If _parent_domain_ id not set, your cluster will use [nip.io](https://nip.io/) in order to create publicly resolvable URLs of the form ht<span>tp://\<app-name\>-\<environment-name\>.\<cluster-ip\>.nip.io.

## How do I contribute
<a id="markdown-how-do-i-contribute" name="how-do-i-contribute"></a>

Contributions are very welcome! Check out the [Contribution Guidelines](./CONTRIBUTING.md) for instructions.
