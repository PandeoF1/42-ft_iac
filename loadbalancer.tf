# module "lb-http" {
#   source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
#   version = "~> 12.0"
# 
#   name    = var.name
#   project = var.project_id
# 
#   ssl                             = true
#   managed_ssl_certificate_domains = [var.domain] # Désactivé pour éviter un conflit avec Cloudflare
#   https_redirect                  = true
#   #certificate                     = cloudflare_origin_ca_certificate.default.certificate
# 
#   backends = {
#     default = {
#       protocol = "HTTP"
#       groups = [
#         {
#           group = google_compute_region_network_endpoint_group.default.id
#         }
#       ]
#       enable_cdn = false
#       iap_config = {
#         enable = false
#       }
#       log_config = {
#         enable = false
#       }
#     }
#   }
# }
# 
# resource "google_compute_region_network_endpoint_group" "default" {
#   provider              = google-beta
#   name                  = var.name
#   network_endpoint_type = "SERVERLESS"
#   region                = var.regions[var.zone].region
#   cloud_run {
#     service = google_cloud_run_v2_service.default.name
#   }
# }
# 
# output "external_url" {
#   value = module.lb-http.external_ip
# }