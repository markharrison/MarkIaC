# Azure Infrastructure as Code

This directory contains Terraform configuration files for deploying the MarkIaC infrastructure to Azure.

## Architecture

The infrastructure includes:

- **Managed Identity**: User-assigned identity for password-less service-to-service authentication
- **App Service**: S1 Linux App Service Plan running .NET 8 (deployed to UK South by default)
- **Azure SQL Database**: Basic tier with Entra ID-only authentication (no SQL passwords)
- **Monitoring**: Log Analytics Workspace and Application Insights with diagnostic settings
- **Azure OpenAI**: GPT-4o deployment in Sweden Central
- **Azure AI Search**: Basic tier search service

## Prerequisites

1. Azure subscription
2. Terraform >= 1.0 installed
3. Azure CLI installed and authenticated
4. Entra ID (Azure AD) administrator credentials for SQL Server

## Configuration

### Required Variables

The following variables must be provided:

- `sql_admin_object_id`: Object ID of the Entra ID admin for SQL Server
- `sql_admin_login`: Entra ID admin login name for SQL Server

### Optional Variables (with defaults)

- `resource_group_name`: Name of the resource group (default: `rg-markiac`)
- `location`: Azure region for main resources (default: `uksouth`)
- `openai_location`: Azure region for OpenAI resources (default: `swedencentral`)
- `project_name`: Project name for resource naming (default: `markiac`)
- `environment`: Environment name (default: `dev`)

### Creating a Variables File

Create a `terraform.tfvars` file (gitignored) with your configuration:

```hcl
resource_group_name  = "rg-markiac-dev"
location             = "uksouth"
openai_location      = "swedencentral"
project_name         = "markiac"
environment          = "dev"
sql_admin_object_id  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
sql_admin_login      = "admin@yourdomain.com"

tags = {
  Project     = "MarkIaC"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Your Name"
}
```

## Deployment

### Local Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Validate configuration:**
   ```bash
   terraform validate
   ```

3. **Plan deployment:**
   ```bash
   terraform plan
   ```

4. **Apply configuration:**
   ```bash
   terraform apply
   ```

### GitHub Actions Deployment

Use the included GitHub workflows for automated deployment:

1. **Deploy Infrastructure**: Run the `Deploy Infrastructure` workflow from GitHub Actions
2. **Delete Infrastructure**: Run the `Delete Infrastructure` workflow to tear down resources

For GitHub Actions to work, you need to set up OIDC authentication. See [oidc.md](../oidc.md) for detailed instructions.

## Outputs

After successful deployment, Terraform outputs the following information:

- Resource group name
- Managed identity IDs
- App Service name and hostname
- SQL Server and database names
- Log Analytics workspace ID
- Application Insights connection string
- Azure OpenAI endpoint
- Azure AI Search endpoint

View outputs:
```bash
terraform output
```

## Resource Naming Convention

Resources follow this naming pattern:
- Resource Group: `rg-{project}-{environment}`
- Managed Identity: `id-{project}-{environment}`
- App Service Plan: `asp-{project}-{environment}`
- App Service: `app-{project}-{environment}`
- SQL Server: `sql-{project}-{environment}`
- SQL Database: `sqldb-{project}-{environment}`
- Log Analytics: `log-{project}-{environment}`
- Application Insights: `appi-{project}-{environment}`
- Azure OpenAI: `oai-{project}-{environment}`
- AI Search: `srch-{project}-{environment}`

## Security Features

1. **Entra ID-only authentication** for Azure SQL (no SQL passwords)
2. **Managed Identity** for service-to-service authentication
3. **RBAC** assignments for least-privilege access
4. **TLS 1.2** minimum for SQL Server
5. **Transparent Data Encryption** enabled for SQL Database
6. **Application Insights** for security monitoring and diagnostics

## State Management

For production use, consider configuring a remote backend for Terraform state:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "markiac.tfstate"
  }
}
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

Or use the GitHub Actions "Delete Infrastructure" workflow.

## Troubleshooting

### SQL Server Admin Configuration

To find your Entra ID Object ID:
```bash
az ad user show --id admin@yourdomain.com --query id -o tsv
```

### OpenAI Model Availability

GPT-4o might not be available in all regions. The configuration uses Sweden Central as the default location for OpenAI resources. If deployment fails, check model availability in your region:
```bash
az cognitiveservices account list-models \
  --resource-group <rg-name> \
  --name <openai-account-name> \
  --query "[?name=='gpt-4o']"
```

### Resource Name Conflicts

Azure requires globally unique names for some resources (SQL Server, Storage Accounts, App Services, OpenAI, AI Search). If you encounter naming conflicts, modify the `project_name` or `environment` variables to ensure uniqueness.

## Support

For issues or questions, please open an issue in the GitHub repository.
