output "id" {
  value = azurerm_cosmosdb_account.default.id
}

output "primary_connection_tring" {
  value     = azurerm_cosmosdb_account.default.connection_strings[0]
  sensitive = true
}

output "secondary_connection_tring" {
  value     = azurerm_cosmosdb_account.default.connection_strings[1]
  sensitive = true
}
