output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.voteapp_aks.id
}

output "cosmos_subnet_id" {
  value = azurerm_subnet.voteapp_cosmos.id
}

output "keyvault_subnet_id" {
  value = azurerm_subnet.voteapp_keyvault.id
}
