# MarkIaC

Infrastructure as Code for deploying Azure resources using Terraform.

## Overview

This repository contains Terraform configuration files and GitHub workflows for deploying and managing Azure infrastructure, including:

- **App Service** - S1 Linux plan with .NET 8 runtime
- **Azure SQL Database** - Entra ID-only authentication (passwordless)
- **Managed Identity** - User-assigned identity for service-to-service authentication
- **Monitoring** - Log Analytics and Application Insights with diagnostic settings
- **Azure OpenAI** - GPT-4o deployment
- **Azure AI Search** - AI-powered search service

## Getting Started

### Prerequisites

- Azure subscription
- Terraform >= 1.0
- Azure CLI (for local deployment)
- GitHub repository access (for GitHub Actions deployment)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/markharrison/MarkIaC.git
   cd MarkIaC
   ```

2. **Configure variables:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

For detailed instructions, see [terraform/README.md](terraform/README.md).

## GitHub Actions Deployment

This repository includes GitHub workflows for automated infrastructure deployment:

- **Deploy Infrastructure** - Deploys all Azure resources
- **Delete Infrastructure** - Tears down all resources

To use GitHub Actions, you need to configure OIDC authentication between GitHub and Azure. See [oidc.md](oidc.md) for step-by-step instructions.

## Documentation

- [Terraform Configuration](terraform/README.md) - Detailed Terraform documentation
- [OIDC Setup Guide](oidc.md) - GitHub Actions to Azure authentication setup

## Architecture

The infrastructure uses best practices for security and observability:

- **Passwordless authentication** - Managed identities and Entra ID
- **Monitoring** - Comprehensive diagnostic settings and Application Insights
- **Security** - RBAC, TLS 1.2+, and encrypted storage
- **Scalability** - Configurable tiers and locations

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
