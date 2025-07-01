resource "google_project" "uat" {
  name       = "UAT Project"
  project_id = "uat-project-id"
  org_id     = var.org_id
  billing_account = var.billing_account

  iam_member {
    role   = "roles/owner"
    member = "user:${var.owner_email}"
  }

  depends_on = [google_project.shared]
}

module "uat_vpc" {
  source = "../../modules/vpc"

  project_id = google_project.uat.project_id
  region     = var.region
}

resource "google_project_service" "uat_services" {
  project = google_project.uat.project_id
  service = var.enabled_services
}

output "uat_project_id" {
  value = google_project.uat.project_id
}

output "uat_vpc_name" {
  value = module.uat_vpc.vpc_name
}