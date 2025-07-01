resource "google_project" "dev_project" {
  name       = "Dev Project"
  project_id = "dev-project-id"
  org_id     = var.org_id
  billing_account = var.billing_account

  iam_member {
    role   = "roles/owner"
    member = "user:${var.dev_owner_email}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

module "dev_vpc" {
  source = "../../modules/vpc"

  project_id = google_project.dev_project.project_id
  region     = var.region
}

resource "google_project_service" "dev_services" {
  project = google_project.dev_project.project_id
  service = var.enabled_services
}

output "dev_project_id" {
  value = google_project.dev_project.project_id
}