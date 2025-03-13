# Règle de transfert global
resource "google_compute_global_forwarding_rule" "lb" {
  name       = "${var.name}-lb"
  target     = google_compute_target_http_proxy.app_proxy.self_link
  port_range = "3000"
}

# Proxy HTTP de l'application
resource "google_compute_target_http_proxy" "app_proxy" {
  name    = "${var.name}-proxy"
  url_map = google_compute_url_map.app_url_map.self_link
}

# Mappage des URL
resource "google_compute_url_map" "app_url_map" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.app_backend.self_link
}

# Backend service de l'application
resource "google_compute_backend_service" "app_backend" {
  name          = "${var.name}-backend"
  port_name     = "http"
  protocol      = "HTTP"
  timeout_sec   = 30
  health_checks = [google_compute_http_health_check.app_health_check.self_link]

  backend {
    group = google_compute_region_instance_group_manager.app_group.instance_group
  }
  
  session_affinity = var.session_under_redis ? null : "CLIENT_IP"
}

# Vérification de l'état de l'application
resource "google_compute_http_health_check" "app_health_check" {
  name                = "${var.name}-health-check"
  request_path        = "/health/liveness"
  port                = "3000"
  check_interval_sec  = 15
  timeout_sec         = 2
}

output "lb_ip" {
  value = google_compute_global_forwarding_rule.lb.ip_address
}
