# Azure SQL Server
resource "azurerm_mssql_server" "main" {
  name                          = "sql-${var.project_name}-${var.environment}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  azuread_administrator {
    login_username              = var.sql_admin_login
    object_id                   = var.sql_admin_object_id
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name         = "sqldb-${var.project_name}-${var.environment}"
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb  = 2
  sku_name     = "Basic"
  zone_redundant = false

  tags = var.tags
}

# Grant managed identity access to SQL Database
resource "azurerm_mssql_server_transparent_data_encryption" "main" {
  server_id = azurerm_mssql_server.main.id
}

# Role assignment for managed identity to access SQL
resource "azurerm_role_assignment" "sql_contributor" {
  scope                = azurerm_mssql_server.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
