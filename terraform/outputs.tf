output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "managed_identity_id" {
  description = "The ID of the managed identity"
  value       = azurerm_user_assigned_identity.app.id
}

output "managed_identity_client_id" {
  description = "The client ID of the managed identity"
  value       = azurerm_user_assigned_identity.app.client_id
}

output "app_service_name" {
  description = "The name of the App Service"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  description = "The default hostname of the App Service"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "sql_server_name" {
  description = "The name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_database_name" {
  description = "The name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "openai_endpoint" {
  description = "The endpoint for Azure OpenAI"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "search_service_name" {
  description = "The name of the Azure AI Search service"
  value       = azurerm_search_service.main.name
}

output "search_service_endpoint" {
  description = "The endpoint for Azure AI Search"
  value       = "https://${azurerm_search_service.main.name}.search.windows.net"
}
