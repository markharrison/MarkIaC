variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-markiac"
}

variable "location" {
  description = "Azure region for main resources"
  type        = string
  default     = "uksouth"
}

variable "openai_location" {
  description = "Azure region for OpenAI resources"
  type        = string
  default     = "swedencentral"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "markiac"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "MarkIaC"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "sql_admin_object_id" {
  description = "Object ID of the Entra ID admin for SQL Server"
  type        = string
}

variable "sql_admin_login" {
  description = "Entra ID admin login name for SQL Server"
  type        = string
}
