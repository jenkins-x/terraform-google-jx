output "jenkins_x_namespace" {
  value = length(kubernetes_namespace.jenkins_x_namespace) > 0 ? kubernetes_namespace.jenkins_x_namespace[0].metadata[0].name : var.jenkins_x_namespace
}
