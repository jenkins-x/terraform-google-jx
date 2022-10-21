// ----------------------------------------------------------------------------
// Create and configure the Argo CD installation
//
// ----------------------------------------------------------------------------
locals {}

resource "helm_release" "bootstrap" {
  provider         = helm
  name             = "argocd"
  chart            = "argo-cd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "5.52.1"
  create_namespace = true
  values = [
    jsonencode(
      {
        "configs" : {
          "cm" : {
            "resource.compareoptions" : "ignoreAggregatedRoles: true"
          }
        },
        "controller" : {
          "serviceAccount" : {
            "annotations" : {
              "iam.gke.io/gcp-service-account" : "argocd-${var.cluster_name}@${var.gcp_project}.iam.gserviceaccount.com"
            }
          },
        },
        "repoServer" : {
          "autoscaling" : {
            "enabled" : true,
            "minReplicas" : 2
          },
          "initContainers" : [
            {
              "name" : "download-tools",
              "image" : "ghcr.io/helmfile/helmfile:v0.147.0",
              "command" : [
                "sh",
                "-c"
              ],
              "args" : [
                "wget -qO /custom-tools/argo-cd-helmfile.sh https://raw.githubusercontent.com/travisghansen/argo-cd-helmfile/master/src/argo-cd-helmfile.sh && chmod +x /custom-tools/argo-cd-helmfile.sh && mv /usr/local/bin/helmfile /custom-tools/helmfile"
              ],
              "volumeMounts" : [
                {
                  "mountPath" : "/custom-tools",
                  "name" : "custom-tools"
                }
              ]
            }
          ],
          "serviceAccount" : {
            "annotations" : {
              "iam.gke.io/gcp-service-account" : "argocd-${var.cluster_name}@${var.gcp_project}.iam.gserviceaccount.com"
            }
          },
          "volumes" : [
            {
              "name" : "custom-tools",
              "emptyDir" : {}
            }
          ],
          "volumeMounts" : [
            {
              "mountPath" : "/usr/local/bin/argo-cd-helmfile.sh",
              "name" : "custom-tools",
              "subPath" : "argo-cd-helmfile.sh"
            },
            {
              "mountPath" : "/usr/local/bin/helmfile",
              "name" : "custom-tools",
              "subPath" : "helmfile"
            }
          ]
        },
        "server" : {
          "autoscaling" : {
            "enabled" : true,
            "minReplicas" : 2
          }
          "ingress" : {
            "enabled" : true,
            "annotations" : {
              "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS",
              "nginx.ingress.kubernetes.io/force-ssl-redirect" : "true",
              "nginx.ingress.kubernetes.io/ssl-passthrough" : "true"
            },
            "hosts" : [
              "argocd.${var.apex_domain}"
            ],
            "serviceAccount" : {
              "annotations" : {
                "iam.gke.io/gcp-service-account" : "argocd-${var.cluster_name}@${var.gcp_project}.iam.gserviceaccount.com"
              }
            }
          }
        }
      }
    )
  ]

  set {
    name  = "configs.cm.configManagementPlugins"
    value = <<-EOT
    - name: helmfile
      init:                          # Optional command to initialize application source directory
        command: ["argo-cd-helmfile.sh"]
        args: ["init"]
      generate:                      # Command to generate manifests YAML
        command: ["argo-cd-helmfile.sh"]
        args: ["generate"]
    EOT
  }
  set {
    name  = "configs.credentialTemplates.https-creds.url"
    value = regex("\\w+://\\w+\\.\\w+", var.jx_git_url)
  }
  set_sensitive {
    name  = "configs.credentialTemplates.https-creds.username"
    value = var.jx_bot_username
  }
  set_sensitive {
    name  = "configs.credentialTemplates.https-creds.password"
    value = var.jx_bot_token
  }

  dynamic "set" {
    for_each = var.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }

  lifecycle {
    ignore_changes = all
  }
}
