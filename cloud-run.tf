resource "google_cloud_run_v2_service" "default" {
  name     = var.name
  location = var.regions[var.zone].region
  deletion_protection = var.deletion_protection
  ingress = "INGRESS_TRAFFIC_ALL"
  template {
    containers {
      image = "docker.io/pandeo/ft-iac:ta"
      env {
        name = "MYSQL_HOST"
        value = google_sql_database_instance.instance.private_ip_address
      }
      env {
        name = "MYSQL_USER"
        value = google_sql_user.users.name
      }
      env {
        name = "MYSQL_PASSWORD"
        value = google_sql_user.users.password
      }
      env {
        name = "MYSQL_DATABASE"
        value = google_sql_database.database.name
      }
      env {
        name = "NODE_ENV"
        value = "production"
      }

      ports {
        container_port = 3000
      }

      resources {
        limits = {
          cpu    = var.cloud_run_size[var.size].cpu
          memory = var.cloud_run_size[var.size].memory
        }
      }
    }
    scaling {
      min_instance_count = 2
      max_instance_count = 2
    }
    vpc_access{
      network_interfaces {
        network = google_compute_network.vpc_network.name
        subnetwork = google_compute_subnetwork.vpc_subnet.name
      }
    }
  }
}
