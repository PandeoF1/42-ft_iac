resource "google_redis_instance" "cache" {
  # Only if session_under_redis is true
  count          = var.session_under_redis ? 1 : 0
  name           = var.name
  memory_size_gb = 1

  lifecycle {
    prevent_destroy = false
  }

  authorized_network = google_compute_network.vpc_network.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  depends_on = [google_compute_network.vpc_network, google_service_networking_connection.private_vpc_connection]
}

output "redis_host" {
  value = var.session_under_redis ? "${google_redis_instance.cache[0].host}:${google_redis_instance.cache[0].port}" : ""
}
