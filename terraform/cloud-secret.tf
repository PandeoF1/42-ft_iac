resource "random_string" "session_secret" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "random_string" "sql_secret" {
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
  secret_data = random_string.session_secret.result
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
