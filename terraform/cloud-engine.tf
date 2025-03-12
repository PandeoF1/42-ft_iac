resource "google_compute_instance_template" "app" {
  name         = "${var.name}-template"
  machine_type = var.machine_type
  region       = var.regions[var.zone].region

  disk {
    source_image = var.app_artifact_id
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "MYSQL_HOST=${google_sql_database_instance.instance.private_ip_address}" >> /etc/environment
    echo "MYSQL_USER=${google_sql_user.users.name}" >> /etc/environment
    echo "MYSQL_DATABASE=${google_sql_database.database.name}" >> /etc/environment
    echo "REDIS_HOST=${google_redis_instance.cache.host}" >> /etc/environment
    echo "REDIS_PORT=${google_redis_instance.cache.port}" >> /etc/environment
    echo "NODE_ENV=production" >> /etc/environment
    echo "SESSION_SECRET=$(gcloud secrets versions access latest --secret=${google_secret_manager_secret.secret_session.secret_id})" >> /etc/environment
    echo "MYSQL_PASSWORD=$(gcloud secrets versions access latest --secret=${google_secret_manager_secret.secret_database.secret_id})" >> /etc/environment
    source /etc/environment
    systemctl restart app.service
  EOT
}

# output "service_url" {
#   value = google_cloud_run_v2_service.default.urls
# }
# 
# output "redis_insight_url" {
#   value = google_cloud_run_v2_service.redis_insight.urls
# }
# 
# data "google_project" "project" {
#   project_id = var.project_id
# }
