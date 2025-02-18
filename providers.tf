provider "google" {
  project     = var.project_id
  region      = var.regions[var.zone].region
}
