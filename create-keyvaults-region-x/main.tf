terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.109.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "av-keyvault-x"
  location = "eastus2"
}

// Create Key Vaults
resource "azurerm_key_vault" "example" {
  count               = 250
  name                = "${azurerm_resource_group.example.name}-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = "62e9dca3-7396-48ed-a055-61c12fc24020"
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled = false

  access_policy {
    tenant_id = "62e9dca3-7396-48ed-a055-61c12fc24020"
    object_id = "4ce64cff-e3f2-443b-92af-fe88a51a6f8d"
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]
  }

   tags = {
    Environment = "Production"
    Department  = "IT"
    Project     = "KeyVaultProject"
    Owner       = "JohnDoe"
    CostCenter  = "12345"
    Application = "AppName"
    Team        = "DevOps"
    Compliance  = "Yes"
    Backup      = "Enabled"
    Monitoring  = "Enabled"
  }
}
