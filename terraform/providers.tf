terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "google" {
  credentials = file("../gcp.json")
  project     = var.project_id
  region      = var.area[var.region].region
}

provider "google-beta" {
  credentials = file("../gcp.json")
  project     = var.project_id
  region      = var.area[var.region].region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}