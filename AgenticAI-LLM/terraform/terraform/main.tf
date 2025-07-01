terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "private" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.0.0/20"
  network       = google_compute_network.vpc.id
  region        = var.region

  private_ip_google_access = true
  
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.1.0.0/20"
  }
}

# Cloud SQL
resource "google_sql_database_instance" "main" {
  name             = "learning-saas-db"
  database_version = "POSTGRES_13"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
    backup_configuration {
      enabled = true
    }
  }
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "learning-saas-gke"
  location = var.region

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.private.name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "services-range"
    services_secondary_range_name = "cluster-range"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.authorized_networks
      display_name = "Authorized network"
    }
  }
}

# Cloud Storage
resource "google_storage_bucket" "content" {
  name          = "${var.project_id}-content"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
}

# Redis Instance
resource "google_redis_instance" "cache" {
  name           = "learning-saas-cache"
  tier           = "BASIC"
  memory_size_gb = 1

  location_id             = var.zone
  authorized_network      = google_compute_network.vpc.id
  connect_mode           = "PRIVATE_SERVICE_ACCESS"
}

# IAM
resource "google_service_account" "app_sa" {
  account_id   = "learning-saas-sa"
  display_name = "Learning SaaS Service Account"
}

resource "google_project_iam_member" "app_sa_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/cloudsql.client",
    "roles/redis.viewer"
  ])
  
  role    = each.key
  member  = "serviceAccount:${google_service_account.app_sa.email}"
  project = var.project_id
}