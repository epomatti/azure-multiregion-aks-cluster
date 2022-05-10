data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "default" {
  name                       = "kv-${var.root_name}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.aks_subnet_id, var.jumpbox_subnet_id, var.backup_jumpbox_subnet_id]
  }

  sku_name = "standard"

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "superadmin" {
  key_vault_id = azurerm_key_vault.default.id

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

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.default.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = var.aks_service_principal_object_id

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_secret" "cosmos" {
  name         = "cosmosdb-connection-string"
  value        = var.cosmos_connection_string
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [
    azurerm_key_vault_access_policy.superadmin
  ]
}

resource "azurerm_key_vault_secret" "hello" {
  name         = "my-secret"
  value        = "hello"
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [
    azurerm_key_vault_access_policy.superadmin
  ]
}
