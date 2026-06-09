# GitHub OIDC trust with Azure

Use these steps to enable password-less trust between GitHub Actions and Azure.

## 1) Create app registration and service principal

```bash
az ad app create --display-name markiac-gh-oidc
APP_ID=$(az ad app list --display-name markiac-gh-oidc --query "[0].appId" -o tsv)
az ad sp create --id "$APP_ID"
```

## 2) Add federated credential for this repository

Replace `<ORG>`, `<REPO>`, and branch if needed:

```bash
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<ORG>/<REPO>:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## 3) Grant Azure RBAC permissions

Grant the service principal rights at subscription or resource-group scope:

```bash
SUBSCRIPTION_ID="<subscription-id>"
SP_OBJECT_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

For SQL Entra admin setup in the template, also grant Graph directory read access as required by your tenant policy.

## 4) Configure repository secrets/variables

Set these repository **Secrets**:

- `AZURE_CLIENT_ID` = app registration `appId`
- `AZURE_TENANT_ID` = Azure tenant ID
- `AZURE_SUBSCRIPTION_ID` = subscription ID

Set these repository **Variables**:

- `AZURE_SQL_ADMIN_OBJECT_ID` = Entra object ID for SQL admin
- `AZURE_SQL_ADMIN_LOGIN` = Entra UPN/login for SQL admin

## 5) Run workflows

- Use **Deploy infrastructure** workflow and provide `resourceGroup` (and optional location overrides).
- Use **Delete infrastructure** workflow to tear down by resource group.
