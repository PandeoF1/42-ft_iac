module "lb-http" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 12.0"

  name    = var.name
  project = var.project_id

  ssl                             = true
  managed_ssl_certificate_domains = [var.domain] # Désactivé pour éviter un conflit avec Cloudflare
  https_redirect                  = true
  certificate                     = cloudflare_origin_ca_certificate.default.certificate

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.default.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "default" {
  provider              = google-beta
  name                  = var.name
  network_endpoint_type = "SERVERLESS"
  region                = var.regions[var.zone].region
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

# Ajout d'un enregistrement DNS Cloudflare
resource "cloudflare_dns_record" "lb" {
  zone_id = var.cloudflare_zone_id
  comment = "Domain verification record"
  content = module.lb-http.external_ip
  name = var.domain
  proxied = true
  ttl = 1
  type = "A"
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "tls_cert_request" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  subject {
    common_name  = var.domain
    organization = "ACME Company"
  }
}

resource "cloudflare_origin_ca_certificate" "default" {
  csr                = tls_cert_request.default.cert_request_pem
  hostnames          = [ var.domain ]
  request_type       = "origin-rsa"
  requested_validity = 7
}