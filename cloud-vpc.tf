resource "google_compute_network" "vpc_network" {
  name     = var.name
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
