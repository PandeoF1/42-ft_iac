provider "google" {
  project     = var.project_id
  region      = var.regions[var.zone].region
}

provider "google-beta" {
  project     = var.project_id
  region      = var.regions[var.zone].region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}