resource "google_service_account" "app_sa" {
  account_id   = "app-sa"
  display_name = "App Service Account"
}

resource "google_compute_instance_template" "app_template" {
  name         = "${var.name}-template"
  # name         = "${var.name}-template-${local.timestamp_sanitized}"
  machine_type = var.cloud_engine_size[var.size].tier

  tags = ["http-server", "https-server", "ssh-enabled"] # Ajout des tags pour autoriser HTTP et HTTPS

  disk {# For the source image get ../terraform/packer/manifest-app.json -> builds -> latest -> artifact_id
    source_image = jsondecode(file("../packer/manifest-app.json")).builds[0].artifact_id
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    # access_config {
    #   // Ephemeral IP
    # }
  }
  lifecycle {
    create_before_destroy = true  # Ensure new templates are created before old ones are deleted
  }

  metadata_startup_script = <<-EOT
    #! /bin/bash
    cat <<EOF > /home/ubuntu/docker/docker-compose.yaml
    services:
      app:
        build:
          context: .
          dockerfile: Dockerfile
        restart: always
        ports:
          - "3000:3000" 
        environment:
          - DB_INIT_SYNC=true
          - MYSQL_HOST=${google_sql_database_instance.master.private_ip_address}
          - MYSQL_USER=${google_sql_user.users.name}
          - MYSQL_DATABASE=${google_sql_database.database.name}
          - NODE_ENV=production
          - SESSION_SECRET=${random_password.session_secret.result}
          - MYSQL_PASSWORD=${random_password.sql_secret.result}
    EOF

    %{ if var.session_under_redis }
    echo "      - REDIS_HOST=${google_redis_instance.cache[0].host}" >> /home/ubuntu/docker/docker-compose.yaml
    echo "      - REDIS_PORT=${google_redis_instance.cache[0].port}" >> /home/ubuntu/docker/docker-compose.yaml
    %{ endif }

    chown ubuntu:ubuntu /home/ubuntu/docker/docker-compose.yaml
    docker compose -f /home/ubuntu/docker/docker-compose.yaml up -d
    echo "Docker compose started"
  EOT
    # docker compose -f /home/ubuntu/docker/docker-compose.yaml up -d
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.app_sa.email
    scopes = ["cloud-platform"]
  }
  depends_on = [ google_sql_database.database, google_redis_instance.cache, google_sql_database_instance.master ]
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 15
  timeout_sec         = 2
  unhealthy_threshold = 4
  healthy_threshold   = 2
  http_health_check {
    request_path = "/health/readiness"
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
  

  update_policy {
    type            = "PROACTIVE"  
    minimal_action  = "REPLACE"

    # Ensure maxSurge is valid for regional groups
    max_surge_fixed = length(var.area[var.region].zones)
    max_unavailable_fixed = 0
  }

  auto_healing_policies {
    health_check = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }
  depends_on = [ google_compute_instance_template.app_template ]
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

data "google_project" "project" {
  project_id = var.project_id
}
