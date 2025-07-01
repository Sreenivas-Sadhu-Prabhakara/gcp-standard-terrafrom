resource "google_project_iam_member" "shared_security_admin" {
  project = var.project_id
  role    = "roles/securityAdmin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "shared_security_viewer" {
  project = var.project_id
  role    = "roles/securityViewer"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "shared_logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "shared_logging_viewer" {
  project = var.project_id
  role    = "roles/logging.viewer"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "shared_security_center_admin" {
  project = var.project_id
  role    = "roles/securitycenter.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "shared_security_center_viewer" {
  project = var.project_id
  role    = "roles/securitycenter.viewer"
  member  = "serviceAccount:${var.service_account_email}"
}