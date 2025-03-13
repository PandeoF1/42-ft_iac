resource "google_sql_database_instance" "master" {
  name             = var.name
  region           = var.area[var.region].region
  database_version = "MYSQL_8_4"
  settings {
    edition = "ENTERPRISE"
    backup_configuration {
      enabled = var.backups
      binary_log_enabled = true
    }

    tier = var.cloud_sql_size[var.size].tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
    availability_type = var.availability_type
    location_preference {
      zone = var.area[var.region].zones[0]  # Assign master to the first zone in the list
    }
  }
  deletion_protection = var.deletion_protection
  depends_on = [google_compute_network.vpc_network, google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database_instance" "replicas" {
  for_each = toset(slice(var.area[var.region].zones, 1, length(var.area[var.region].zones))) # Skip the first zone

  name                 = "${var.name}-replica-${each.value}"
  region               = var.area[var.region].region
  database_version     = "MYSQL_8_4"
  master_instance_name = google_sql_database_instance.master.name
  
  settings {
    edition = "ENTERPRISE"
    tier = var.cloud_sql_size[var.size].tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
    availability_type = var.availability_type
    location_preference {
      zone = each.value  # Assign replica to each zone in the list
    }
  }
  deletion_protection = var.deletion_protection
  depends_on = [google_compute_network.vpc_network, google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "database" {
  name     = var.name
  instance = google_sql_database_instance.master.name
  deletion_policy = "ABANDON"
  depends_on = [google_compute_network.vpc_network, google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_user" "users" {
  name     = var.name
  instance = google_sql_database_instance.master.name
  host     = "%"
  password = random_password.sql_secret.result
}

output "master_private_ip" {
  value = google_sql_database_instance.master.private_ip_address
}

output "replica_private_ips" {
  value = { for k, v in google_sql_database_instance.replicas : k => v.private_ip_address }
}
