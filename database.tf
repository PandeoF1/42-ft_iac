resource "google_sql_database" "database" {
  name     = var.name
  instance = google_sql_database_instance.instance.name
  deletion_policy = "ABANDON"
}

resource "google_sql_database_instance" "instance" {
  name             = var.name
  region           = var.regions[var.zone].region
  database_version = "MYSQL_8_0"
  settings {
    backup_configuration {
      enabled = var.backups
    }

    tier = var.cloud_sql_size[var.size].tier
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
    availability_type = var.availability_type
  }
  deletion_protection  = var.deletion_protection
}

resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "google_sql_user" "users" {
  name     = var.name
  instance = google_sql_database_instance.instance.name
  host     = "%"
  password = random_string.random.result
}
