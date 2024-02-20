resource "helm_release" "longhorn" {
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  namespace        = "longhorn-system"
  chart            = "longhorn"
  create_namespace = true
  values           = [file("${path.module}/values/longhorn.values.yaml")]

  #   version          = "0.14.3"
}