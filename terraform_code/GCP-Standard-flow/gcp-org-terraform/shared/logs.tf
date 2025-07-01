resource "google_logging_project_sink" "shared_logs" {
  name        = "shared-logs-sink"
  project     = var.shared_project_id
  destination = "bigquery.googleapis.com/projects/${var.shared_project_id}/datasets/shared_logs_dataset"
  filter      = "logName:projects/${var.shared_project_id}/logs/"

  iam_member {
    role   = "roles/logging.logWriter"
    member = "serviceAccount:${google_service_account.shared_logs_sa.email}"
  }
}

resource "google_service_account" "shared_logs_sa" {
  account_id   = "shared-logs-sa"
  display_name = "Shared Logs Service Account"
  project      = var.shared_project_id
}

resource "google_logging_project_exclusion" "exclude_private_logs" {
  name        = "exclude-private-logs"
  project     = var.shared_project_id
  filter      = "logName:projects/${var.shared_project_id}/logs/private_logs"
  disabled    = false
}