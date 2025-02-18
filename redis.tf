resource "google_redis_instance" "cache" {
  name           = var.name
  memory_size_gb = 1

  lifecycle {
    prevent_destroy = false
  }

  authorized_network = google_compute_network.vpc_network.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
}
