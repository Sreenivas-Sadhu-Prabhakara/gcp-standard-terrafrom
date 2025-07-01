provider "google" {
  credentials = file("<YOUR-CREDENTIALS-FILE>.json")
  project     = var.organization_id
  region      = var.region
}

resource "google_organization" "org" {
  display_name = var.organization_name
  org_id       = var.organization_id
}

module "shared_vpc" {
  source = "./modules/shared_vpc"
}

module "dev_project" {
  source = "./modules/project"
  project_name = var.dev_project_name
  billing_account = var.billing_account
}

module "sit_project" {
  source = "./modules/project"
  project_name = var.sit_project_name
  billing_account = var.billing_account
}

module "uat_project" {
  source = "./modules/project"
  project_name = var.uat_project_name
  billing_account = var.billing_account
}

module "prod_project" {
  source = "./modules/project"
  project_name = var.prod_project_name
  billing_account = var.billing_account
}

output "organization_id" {
  value = google_organization.org.org_id
}

output "dev_project_id" {
  value = module.dev_project.project_id
}

output "sit_project_id" {
  value = module.sit_project.project_id
}

output "uat_project_id" {
  value = module.uat_project.project_id
}

output "prod_project_id" {
  value = module.prod_project.project_id
}