resource "google_project" "sit_project" {
  name       = "SIT Project"
  project_id = "sit-project-id"
  org_id     = var.org_id
  billing_account = var.billing_account

  iam_member {
    role   = "roles/owner"
    member = "user:${var.owner_email}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

module "sit_vpc" {
  source = "../../modules/vpc"

  project_id = google_project.sit_project.project_id
  region     = var.region
}

resource "google_project_service" "sit_services" {
  project = google_project.sit_project.project_id
  service = var.enabled_services
}

output "sit_project_id" {
  value = google_project.sit_project.project_id
}