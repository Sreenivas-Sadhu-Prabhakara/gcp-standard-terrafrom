resource "google_project" "project" {
  for_each = var.projects

  name       = each.value.name
  project_id = each.value.project_id
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

resource "google_project_service" "project_services" {
  for_each = var.projects

  project = google_project.project[each.key].project_id
  service = var.enabled_services
}

resource "google_project_iam_member" "project_iam" {
  for_each = var.projects

  project = google_project.project[each.key].project_id
  role    = var.default_role
  member  = var.default_member
}

output "project_ids" {
  value = { for p in google_project.project : p.project_id => p.name }
}