resource "helm_release" "kube-prometheus-stack" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "monitoring"
  chart            = "kube-prometheus-stack"
  create_namespace = true
#   version          = "4.9.1"
  values = [
    file("${path.module}/values/grafana.values.yaml")
  ]
}