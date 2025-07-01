resource "google_compute_network" "vpc_network" {
  count        = var.project_count
  name         = "${var.project_name[count.index]}-vpc"
  auto_create_subnetworks = false
  project      = var.project_id[count.index]
}

resource "google_compute_subnetwork" "subnetwork" {
  count        = var.project_count
  name         = "${var.project_name[count.index]}-subnet"
  ip_cidr_range = var.subnet_ip_range[count.index]
  region       = var.region
  network      = google_compute_network.vpc_network[count.index].name
  project      = var.project_id[count.index]
}

resource "google_compute_firewall" "allow_ssh" {
  count        = var.project_count
  name         = "${var.project_name[count.index]}-allow-ssh"
  network      = google_compute_network.vpc_network[count.index].name
  project      = var.project_id[count.index]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {
  count        = var.project_count
  name         = "${var.project_name[count.index]}-allow-http"
  network      = google_compute_network.vpc_network[count.index].name
  project      = var.project_id[count.index]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_https" {
  count        = var.project_count
  name         = "${var.project_name[count.index]}-allow-https"
  network      = google_compute_network.vpc_network[count.index].name
  project      = var.project_id[count.index]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}