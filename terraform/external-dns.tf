
data "google_dns_managed_zone" "env_dns_zone" {
  name = "personal"
}

resource "google_service_account" "external_dns" {
  account_id = "homelab-dns"
}

resource "google_dns_managed_zone_iam_member" "member" {
  #   project = google_dns_managed_zone.default.project
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  role         = "roles/dns.admin"
  member       = "serviceAccount:${google_service_account.external_dns.email}"
}

resource "google_project_iam_member" "external-dns" {
  project = "robertb724-personal"
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns.email}"
}

resource "google_service_account_key" "external_dns_creds" {
  service_account_id = google_service_account.external_dns.name
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external_dns_creds" {
  metadata {
    name      = "gcp-sa-key"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.external_dns_creds.private_key)
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  chart      = "external-dns"
  values     = [file("${path.module}/values/external-dns.values.yaml")]
  version    = "1.14.3"


  depends_on = [kubernetes_secret.external_dns_creds]

}
