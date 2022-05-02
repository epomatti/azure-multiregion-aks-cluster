data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "default" {
  name                       = "kv-${var.root_name}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
  }
}


resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.default.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = var.aks_principal_id

  secret_permissions = [
    "Get"
  ]

}

resource "azurerm_key_vault_secret" "cosmos" {
  name         = "cosmosdb-connection-string"
  value        = var.cosmos_connection_string
  key_vault_id = azurerm_key_vault.default.id
}
