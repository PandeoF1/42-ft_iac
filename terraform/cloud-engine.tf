resource "google_compute_instance_template" "app_template" {
  name         = "${var.name}-template"
  machine_type = var.cloud_engine_size[var.size].tier

  disk {
    source_image = "ft-iac-1741789784"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.vpc_network.name
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    cat <<EOF > /home/ubuntu/docker/docker-compose.yaml
    services:
      app:
        build:
          context: .
          dockerfile: Dockerfile
        ports:
          - "3000:3000"
        environment:
          MYSQL_HOST=${google_sql_database_instance.master.private_ip_address}
          MYSQL_USER=${google_sql_user.users.name}
          MYSQL_DATABASE=${google_sql_database.database.name}
          REDIS_HOST=${google_redis_instance.cache.host}
          REDIS_PORT=${google_redis_instance.cache.port}
          NODE_ENV=production
          SESSION_SECRET=${random_string.session_secret.result}
          MYSQL_PASSWORD=${random_string.sql_secret.result}
    EOF
    docker compose -f /home/ubuntu/docker/docker-compose.yaml up -d
  EOT
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "3000"
  }
}


# Définir le groupe d'instances géré pour plusieurs zones
resource "google_compute_region_instance_group_manager" "app_group" {
  name               = "${var.name}-instance-group"
  base_instance_name = "${var.name}-app"
  region             = var.area[var.region].region
  distribution_policy_zones = var.area[var.region].zones
  version {
    instance_template = google_compute_instance_template.app_template.self_link
  }
  named_port {
    name = "http"
    port = 3000
  }
  auto_healing_policies {
    health_check = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }
}

# Autoscaler
resource "google_compute_region_autoscaler" "app_autoscaler" {
  name               = "${var.name}-autoscaler"
  target            = google_compute_region_instance_group_manager.app_group.self_link
  region             = var.area[var.region].region
  autoscaling_policy {
    max_replicas = var.replicas
    min_replicas = 1
    cpu_utilization {
      target = 0.8
    }
  }
}

# output "service_url" {
#   value = google_cloud_run_v2_service.default.urls
# }
# 
# output "redis_insight_url" {
#   value = google_cloud_run_v2_service.redis_insight.urls
# }
# 
data "google_project" "project" {
  project_id = var.project_id
}
