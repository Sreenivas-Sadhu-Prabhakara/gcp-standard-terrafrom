resource "google_compute_shared_vpc_host_project" "host" {
  project = var.shared_vpc_project_id
}

resource "google_compute_shared_vpc_service_project" "dev" {
  host_project = google_compute_shared_vpc_host_project.host.project
  service_project = var.dev_project_id
}

resource "google_compute_shared_vpc_service_project" "sit" {
  host_project = google_compute_shared_vpc_host_project.host.project
  service_project = var.sit_project_id
}

resource "google_compute_shared_vpc_service_project" "uat" {
  host_project = google_compute_shared_vpc_host_project.host.project
  service_project = var.uat_project_id
}

resource "google_compute_shared_vpc_service_project" "prod" {
  host_project = google_compute_shared_vpc_host_project.host.project
  service_project = var.prod_project_id
}

resource "google_compute_subnetwork" "shared_subnet" {
  count        = var.subnet_count
  name         = "${var.shared_vpc_name}-subnet-${count.index}"
  ip_cidr_range = element(var.subnet_ip_ranges, count.index)
  region       = var.region
  network      = google_compute_network.shared_vpc_network.id
}

resource "google_compute_network" "shared_vpc_network" {
  name                    = var.shared_vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "shared_vpc_firewall" {
  name    = "${var.shared_vpc_name}-firewall"
  network = google_compute_network.shared_vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}