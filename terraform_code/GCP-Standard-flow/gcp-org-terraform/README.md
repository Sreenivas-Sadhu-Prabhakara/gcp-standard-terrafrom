# GCP Organization Terraform Setup

This repository contains Terraform configurations for setting up a Google Cloud Platform (GCP) organization with multiple projects, each having its own independent Virtual Private Cloud (VPC). The projects include environments for Development (Dev), System Integration Testing (SIT), User Acceptance Testing (UAT), and Production (Prod). Additionally, a shared VPC is configured for centralized resources such as logging and security.

## Project Structure

The project is organized as follows:

```
gcp-org-terraform
├── modules
│   ├── project          # Module for creating individual GCP projects
│   ├── vpc              # Module for creating independent VPCs
│   └── shared_vpc       # Module for setting up a shared VPC
├── environments
│   ├── dev              # Environment-specific configuration for Development
│   ├── sit              # Environment-specific configuration for SIT
│   ├── uat              # Environment-specific configuration for UAT
│   └── prod             # Environment-specific configuration for Production
├── shared
│   ├── logs.tf          # Shared logging resources configuration
│   ├── security.tf      # Shared security configurations
│   └── security_center.tf # Security center setup for monitoring
├── main.tf              # Root Terraform configuration
├── variables.tf         # Input variables for customization
├── outputs.tf           # Outputs of the Terraform configuration
└── README.md            # Project documentation
```

## Getting Started

1. **Prerequisites**
   - Ensure you have Terraform installed on your machine.
   - Set up a Google Cloud account and create a service account with the necessary permissions.

2. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd gcp-org-terraform
   ```

3. **Configure Variables**
   - Update the `variables.tf` file with your desired project names, regions, and other parameters.

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Plan the Deployment**
   ```bash
   terraform plan
   ```

6. **Apply the Configuration**
   ```bash
   terraform apply
   ```

## Modules

- **Project Module**: Responsible for creating individual GCP projects with necessary settings and IAM roles.
- **VPC Module**: Configures independent VPCs for each project, including subnets and firewall rules.
- **Shared VPC Module**: Sets up a shared VPC for centralized resources.

## Environments

Each environment (Dev, SIT, UAT, Prod) has its own configuration file that utilizes the modules to provision the respective resources.

## Shared Resources

- **Logging**: Centralized logging configuration to capture logs from all projects.
- **Security**: Shared security configurations to enforce policies across projects.
- **Security Center**: Monitors and manages security across all projects.

## License

This project is licensed under the MIT License - see the LICENSE file for details.