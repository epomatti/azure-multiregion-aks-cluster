output "bastion_subnet_id" {
  value = module.bastion.id
}

output "aks_subnet_id" {
  value = module.vnet.aks_subnet_id
}

output "cosmos_subnet_id" {
  value = module.vnet.cosmos_subnet_id
}

output "keyvault_subnet_id" {
  value = module.vnet.keyvault_subnet_id
}
