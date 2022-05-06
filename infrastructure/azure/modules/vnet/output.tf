output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "cosmos_subnet_id" {
  value = azurerm_subnet.cosmos.id
}

output "keyvault_subnet_id" {
  value = azurerm_subnet.keyvault.id
}
