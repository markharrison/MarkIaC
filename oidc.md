# Setting up OIDC for GitHub Actions and Azure

This guide explains how to establish a trust relationship between GitHub Actions and Azure using OpenID Connect (OIDC), enabling password-less authentication for deploying infrastructure.

## Overview

OIDC allows GitHub Actions to authenticate to Azure without storing long-lived credentials as secrets. Instead, GitHub provides short-lived tokens that Azure validates based on pre-configured trust relationships.

## Prerequisites

- Azure subscription with appropriate permissions (Owner or User Access Administrator role)
- GitHub repository access
- Azure CLI installed (for manual setup) or access to Azure Portal

## Step 1: Create an Azure App Registration

1. **Via Azure Portal:**
   - Navigate to **Azure Active Directory** > **App registrations** > **New registration**
   - Name: `github-actions-markiac` (or your preferred name)
   - Supported account types: **Accounts in this organizational directory only**
   - Click **Register**

2. **Via Azure CLI:**
   ```bash
   az ad app create --display-name github-actions-markiac
   ```

3. **Note the following values:**
   - Application (client) ID
   - Directory (tenant) ID
   - Subscription ID

## Step 2: Create a Service Principal

1. **Via Azure Portal:**
   - In your App registration, go to **Certificates & secrets**
   - Note: We won't create a secret; OIDC will be used instead

2. **Via Azure CLI:**
   ```bash
   APP_ID=$(az ad app list --display-name github-actions-markiac --query [0].appId -o tsv)
   az ad sp create --id $APP_ID
   ```

## Step 3: Assign Azure Roles to the Service Principal

Grant the service principal permissions to manage resources in your subscription:

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SP_ID=$(az ad sp list --display-name github-actions-markiac --query [0].id -o tsv)

# Grant Contributor role for the subscription
az role assignment create \
  --assignee $SP_ID \
  --role Contributor \
  --scope /subscriptions/$SUBSCRIPTION_ID
```

Alternatively, you can scope this to a specific resource group if you prefer:

```bash
RESOURCE_GROUP_NAME="rg-markiac"

az role assignment create \
  --assignee $SP_ID \
  --role Contributor \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME
```

## Step 4: Configure Federated Credentials for OIDC

This establishes the trust relationship between GitHub and Azure.

1. **Via Azure Portal:**
   - In your App registration, go to **Certificates & secrets** > **Federated credentials** > **Add credential**
   - Select **GitHub Actions deploying Azure resources**
   - Fill in:
     - **Organization**: Your GitHub username or organization (e.g., `markharrison`)
     - **Repository**: Your repository name (e.g., `MarkIaC`)
     - **Entity type**: Choose based on your workflow trigger:
       - **Environment** (recommended): For workflow_dispatch with environments
       - **Branch**: For specific branch deployments
       - **Pull request**: For PR-based deployments
       - **Tag**: For tag-based deployments
     - **Environment/Branch/PR**: Enter the name (e.g., `dev` for environment)
     - **Name**: A descriptive name (e.g., `github-actions-dev`)
   - Click **Add**

2. **Via Azure CLI:**

   For environment-based deployment:
   ```bash
   APP_OBJECT_ID=$(az ad app list --display-name github-actions-markiac --query [0].id -o tsv)

   az ad app federated-credential create \
     --id $APP_OBJECT_ID \
     --parameters '{
       "name": "github-actions-dev",
       "issuer": "https://token.actions.githubusercontent.com",
       "subject": "repo:markharrison/MarkIaC:environment:dev",
       "audiences": ["api://AzureADTokenExchange"]
     }'
   ```

   For branch-based deployment:
   ```bash
   az ad app federated-credential create \
     --id $APP_OBJECT_ID \
     --parameters '{
       "name": "github-actions-main",
       "issuer": "https://token.actions.githubusercontent.com",
       "subject": "repo:markharrison/MarkIaC:ref:refs/heads/main",
       "audiences": ["api://AzureADTokenExchange"]
     }'
   ```

   **Note:** Replace `markharrison/MarkIaC` with your actual GitHub username/organization and repository name.

## Step 5: Create GitHub Environments (Optional but Recommended)

If you're using environment-based federated credentials:

1. Go to your GitHub repository
2. Navigate to **Settings** > **Environments**
3. Click **New environment**
4. Name it `dev` (or your chosen environment name)
5. (Optional) Add environment protection rules, required reviewers, or wait timers

Repeat for additional environments (e.g., `prod`).

## Step 6: Configure GitHub Repository Secrets

Add the following secrets to your GitHub repository:

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Click **New repository secret** and add:

   - **AZURE_CLIENT_ID**: Your Application (client) ID from Step 1
   - **AZURE_TENANT_ID**: Your Directory (tenant) ID from Step 1
   - **AZURE_SUBSCRIPTION_ID**: Your Azure Subscription ID from Step 1

These are not sensitive secrets but configuration values needed by the OIDC flow.

## Step 7: Test the Connection

Run the "Deploy Infrastructure" workflow from the GitHub Actions tab to verify the OIDC authentication is working correctly.

## Troubleshooting

### Authentication Failures

If you receive authentication errors:

1. **Verify federated credential subject matches workflow:**
   - For environment: `repo:OWNER/REPO:environment:ENVIRONMENT_NAME`
   - For branch: `repo:OWNER/REPO:ref:refs/heads/BRANCH_NAME`

2. **Check the workflow permissions:**
   ```yaml
   permissions:
     id-token: write  # Required for OIDC
     contents: read
   ```

3. **Verify Azure role assignments:**
   ```bash
   az role assignment list --assignee $SP_ID
   ```

### Multiple Environments

If you need to support multiple environments (dev, prod), create separate federated credentials for each:

```bash
# For dev environment
az ad app federated-credential create \
  --id $APP_OBJECT_ID \
  --parameters '{
    "name": "github-actions-dev",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:markharrison/MarkIaC:environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# For prod environment
az ad app federated-credential create \
  --id $APP_OBJECT_ID \
  --parameters '{
    "name": "github-actions-prod",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:markharrison/MarkIaC:environment:prod",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Security Best Practices

1. **Use environments**: Leverage GitHub environments for production deployments with required approvals
2. **Scope permissions**: Limit the service principal to only the permissions it needs
3. **Use resource group scoping**: Instead of subscription-wide Contributor, scope to specific resource groups
4. **Monitor activity**: Enable Azure Activity Log monitoring for the service principal
5. **Rotate credentials**: While OIDC doesn't use long-lived secrets, periodically review and update federated credentials
6. **Review access**: Regularly audit service principal permissions and federated credentials

## Additional Resources

- [Azure OIDC with GitHub Actions](https://docs.microsoft.com/azure/developer/github/connect-from-azure)
- [GitHub Actions OIDC Documentation](https://docs.github.com/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)
