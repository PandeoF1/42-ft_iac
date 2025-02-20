resource "google_cloud_run_v2_service" "default" {
  name                = var.name
  location            = var.regions[var.zone].region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = var.deletion_protection
  template {
    containers {
      image = "docker.io/pandeo/ft-iac:a"
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
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secret_database.secret_id
            version = 1
          }
        }
      }
      env {
        name = "MYSQL_DATABASE"
        value = google_sql_database.database.name
      }
      env {
        name = "REDIS_HOST"
        value = google_redis_instance.cache.host
      }
      env {
        name = "REDIS_PORT"
        value = google_redis_instance.cache.port
      }
      env {
        name = "SESSION_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secret_session.secret_id
            version = 1
          }
        }
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
      max_instance_count = var.replicas
    }
    vpc_access{
      network_interfaces {
        network = google_compute_network.vpc_network.name
      }
    }
  }
  depends_on = [google_compute_network.vpc_network, google_service_networking_connection.private_vpc_connection]
}

resource "google_cloud_run_service_iam_binding" "public_access" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members = ["allUsers"]
}

resource "random_string" "session_secret" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "google_secret_manager_secret" "secret_database" {
  secret_id = "${var.name}-database"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_database" {
  secret = google_secret_manager_secret.secret_database.name
  secret_data = random_string.random.result
}

resource "google_secret_manager_secret" "secret_session" {
  secret_id = "${var.name}-session"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_session" {
  secret = google_secret_manager_secret.secret_session.name
  secret_data = random_string.session_secret.result
}

resource "google_secret_manager_secret_iam_member" "secret-session" {
  secret_id = google_secret_manager_secret.secret_session.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.secret_session]
}

resource "google_secret_manager_secret_iam_member" "secret-database" {
  secret_id = google_secret_manager_secret.secret_database.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.secret_database]
}

resource "google_cloud_run_domain_mapping" "default" {
  location = var.regions[var.zone].region
  name     = var.domain
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.default.name
  }
}

output "service_url" {
  value = google_cloud_run_v2_service.default.urls
}


data "google_project" "project" {
  project_id = var.project_id
}
