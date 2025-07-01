resource "google_security_center_organization_settings" "default" {
  organization = "<YOUR_ORG_ID>"
  enable_security_health_analytics = true
  enable_asset_discovery = true
}

resource "google_security_center_source" "default" {
  display_name = "Shared Security Center"
  description = "Centralized security monitoring for all projects"
  organization = "<YOUR_ORG_ID>"
}

resource "google_security_center_notification_config" "default" {
  notification_config_id = "shared-security-notification"
  description            = "Notification configuration for security alerts"
  pubsub_topic           = "<YOUR_PUBSUB_TOPIC>"
  event_type            = ["google.cloud.securitycenter.v1.Alert"]
  organization          = "<YOUR_ORG_ID>"
}