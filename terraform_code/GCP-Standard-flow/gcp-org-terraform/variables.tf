variable "org_name" {
  description = "The name of the GCP organization."
  type        = string
}

variable "billing_account" {
  description = "The billing account ID to associate with the projects."
  type        = string
}

variable "region" {
  description = "The region to deploy the resources."
  type        = string
  default     = "us-central1"
}

variable "dev_project_id" {
  description = "The project ID for the development environment."
  type        = string
}

variable "sit_project_id" {
  description = "The project ID for the SIT environment."
  type        = string
}

variable "uat_project_id" {
  description = "The project ID for the UAT environment."
  type        = string
}

variable "prod_project_id" {
  description = "The project ID for the production environment."
  type        = string
}

variable "shared_vpc_name" {
  description = "The name of the shared VPC."
  type        = string
}

variable "shared_logs_bucket" {
  description = "The name of the shared logs bucket."
  type        = string
}

variable "shared_security_policy" {
  description = "The shared security policy for all projects."
  type        = string
}