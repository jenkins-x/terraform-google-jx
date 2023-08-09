## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apex\_domain | The apex domain to be allocated to the cluster | `string` | n/a | yes |
| cluster\_name | Name of the Kubernetes cluster | `string` | n/a | yes |
| gcp\_project | The name of the GCP project | `string` | n/a | yes |
| helm\_values | Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/argo/argo-cd | `map(any)` | `{}` | no |
| jx\_bot\_token | Bot token used to interact with the Jenkins X cluster git repository | `string` | `""` | no |
| jx\_bot\_username | Bot username used to interact with the Jenkins X cluster git repository | `string` | `""` | no |
| jx\_git\_url | URL for the Jenins X cluster git repository | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| argocd\_sa | n/a |
| argocd\_sa\_email | n/a |
| argocd\_sa\_name | n/a |

