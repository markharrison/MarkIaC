# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags
}
