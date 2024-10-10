terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "1412f248-f41c-4c92-be6c-28f2700d1037"
}

resource "azurerm_resource_group" "example" {
  name     = "av-keyvault-c"
  location = "australiaeast"
}

// Use existing Key Vaults using locals (the ramge cam be either all key vaults or the ones that are not on the 1st page)
locals {
  key_vault_names = [for i in range(70,79) : "${azurerm_resource_group.example.name}-${i}"]
}

resource "azurerm_key_vault_secret" "example" {
  for_each    = { for kv in local.key_vault_names : kv => kv }
  name        = "secret-${each.key}-latest"
  value       = "secret-value-${each.key}"
  key_vault_id = "/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resourceGroups/${azurerm_resource_group.example.name}/providers/Microsoft.KeyVault/vaults/${each.value}"
}

