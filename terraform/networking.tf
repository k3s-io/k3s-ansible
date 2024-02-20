resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  namespace        = "metallb-system"
  chart            = "metallb"
  create_namespace = true
  version          = "0.14.3"
}

resource "kubernetes_manifest" "metallb_address_pool" {
  manifest = yamldecode(file("./manifests/metallb/ipaddresspool.yaml"))
}

resource "kubernetes_manifest" "metallb-l2_advertisement" {
  manifest = yamldecode(file("./manifests/metallb/l2advertisement.yaml"))
}


resource "helm_release" "nginx" {
  name             = "nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "ingress"
  chart            = "ingress-nginx"
  create_namespace = true
  version          = "4.9.1"
}