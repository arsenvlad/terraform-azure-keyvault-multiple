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
  name     = "av-keyvault-a"
  location = "eastus2"
}

// Use existing Key Vaults using locals
locals {
  key_vault_names = [for i in range(40) : "av-keyvault-a-${i}"]
}

resource "azurerm_key_vault_secret" "example" {
  for_each    = { for kv in local.key_vault_names : kv => kv }
  name        = "secret-${each.key}"
  value       = "secret-value-${each.key}"
  key_vault_id = "/subscriptions/1412f248-f41c-4c92-be6c-28f2700d1037/resourceGroups/av-keyvault-a/providers/Microsoft.KeyVault/vaults/${each.value}"
}

/*
// Create Key Vaults
resource "azurerm_key_vault" "example" {
  count               = 40
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
}

resource "azurerm_key_vault_secret" "example" {
  for_each    = { for kv in azurerm_key_vault.example : kv.name => kv }
  name        = "secret-${each.key}"
  value       = "secret-value-${each.key}"
  key_vault_id = each.value.id
}
*/

/*
// Use existing Key Vaults via data
data "azurerm_key_vault" "example" {
  count               = 40
  name                = "${azurerm_resource_group.example.name}-${count.index}"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault_secret" "example" {
  for_each    = { for kv in data.azurerm_key_vault.example : kv.name => kv }
  name        = "secret-${each.key}"
  value       = "secret-value-${each.key}"
  key_vault_id = each.value.id
}
*/

