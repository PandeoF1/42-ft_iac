resource "google_cloud_run_v2_service" "app" {
  name     = var.name
  location = var.regions[var.zone].region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "ubuntu"
      resources {
        limits = {
          cpu    = var.sizes[var.size].cpu
          memory = var.sizes[var.size].memory
        }
      }
    }
  }
}
