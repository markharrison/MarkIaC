targetScope = 'resourceGroup'

@description('Short project name used for resource naming.')
param projectName string = 'markiac'

@description('Primary location for core resources.')
param location string = 'uksouth'

@description('Location for Azure OpenAI resources.')
param openAiLocation string = 'swedencentral'

@description('Location for Azure AI Search.')
param searchLocation string = location

@description('Azure AD object ID for SQL Entra admin.')
param sqlAdminObjectId string

@description('Azure AD login/U P N for SQL Entra admin.')
param sqlAdminLogin string

@description('Optional override for App Service app name.')
param appServiceName string = '${toLower(projectName)}-app-${uniqueString(resourceGroup().id, 'app')}'

@description('Optional override for SQL database name.')
param sqlDatabaseName string = 'appdb'

var suffix = uniqueString(subscription().id, resourceGroup().id, projectName)
var managedIdentityName = '${toLower(projectName)}-id-${suffix}'
var appServicePlanName = '${toLower(projectName)}-plan-${suffix}'
var logAnalyticsName = '${toLower(projectName)}-law-${suffix}'
var appInsightsName = '${toLower(projectName)}-appi-${suffix}'
var sqlServerName = '${toLower(projectName)}-sql-${suffix}'
var openAiAccountName = '${toLower(projectName)}-aoai-${suffix}'
var aiSearchName = '${toLower(projectName)}-search-${suffix}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      login: sqlAdminLogin
      sid: sqlAdminObjectId
      tenantId: tenant().tenantId
      azureADOnlyAuthentication: true
    }
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: sqlDatabaseName
  parent: sqlServer
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiAccountName
  location: openAiLocation
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAiAccountName
    publicNetworkAccess: 'Enabled'
  }
}

resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: 'gpt-4o'
  parent: openAi
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-05-13'
    }
    raiPolicyName: 'Microsoft.Default'
  }
}

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aiSearchName
  location: searchLocation
  sku: {
    name: 'basic'
  }
  properties: {
    partitionCount: 1
    replicaCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
  }
}

resource appServiceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-law'
  scope: webApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource sqlDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-law'
  scope: sqlServer
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output managedIdentityResourceId string = managedIdentity.id
output appServiceUrl string = 'https://${webApp.properties.defaultHostName}'
output sqlServerResourceId string = sqlServer.id
output sqlDatabaseResourceId string = sqlDatabase.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output openAiEndpoint string = openAi.properties.endpoint
output aiSearchResourceId string = aiSearch.id
