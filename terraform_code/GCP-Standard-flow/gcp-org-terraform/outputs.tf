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

output "dev_vpc_id" {
  value = module.dev_vpc.vpc_id
}

output "sit_vpc_id" {
  value = module.sit_vpc.vpc_id
}

output "uat_vpc_id" {
  value = module.uat_vpc.vpc_id
}

output "prod_vpc_id" {
  value = module.prod_vpc.vpc_id
}

output "shared_vpc_id" {
  value = module.shared_vpc.vpc_id
}

output "shared_logs_bucket" {
  value = module.shared_logs.logs_bucket
}

output "shared_security_policy" {
  value = module.shared_security.security_policy
}

output "security_center_id" {
  value = module.shared_security_center.security_center_id
}