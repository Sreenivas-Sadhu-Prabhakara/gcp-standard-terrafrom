resource "google_project" "prod" {
  name       = "Production Project"
  project_id = "prod-project-id"
  org_id     = "your-org-id"
  billing_account = "your-billing-account-id"

  iam_member {
    role   = "roles/owner"
    member = "user:your-email@example.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}

module "prod_vpc" {
  source = "../../modules/vpc"

  project_id = google_project.prod.project_id
  region     = "us-central1"
}

module "shared_vpc" {
  source = "../../modules/shared_vpc"

  project_id = google_project.prod.project_id
}

resource "google_project_service" "prod_services" {
  project = google_project.prod.project_id
  service = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

output "prod_project_id" {
  value = google_project.prod.project_id
}

output "prod_vpc_name" {
  value = module.prod_vpc.vpc_name
}