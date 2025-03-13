resource "google_compute_network" "vpc_network" {
  name = var.name
}

# resource "google_compute_router" "vpc_router" {
#   name    = "${var.name}-router"
#   region  = var.regions[var.zone].region
#   network = google_compute_network.vpc_network.self_link
#   depends_on = [google_compute_network.vpc_network]
# }

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.vpc_network.id
  depends_on    = [google_compute_network.vpc_network]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [google_compute_global_address.private_ip_address]
}

resource "google_compute_firewall" "allow_ssh_ft_iac" {
  name    = "allow-ssh-ft-iac"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Authorize lb to access the app
resource "google_compute_firewall" "allow_lb" {
  name    = "allow-lb"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "108.170.220.0/23"]
}
