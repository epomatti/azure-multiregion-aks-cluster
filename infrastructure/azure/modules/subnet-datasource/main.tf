# Variables

variable "environemnt" {
  type = string
}

variable "instance" {
  type = string
}

# Params

locals {
  rg_name   = "rg-network-${var.environemnt}-${var.instance}"
  vnet_name = "vnet-network-${var.environemnt}-${var.instance}"
}

# Data Sources

data "azurerm_subnet" "jumpbox" {
  name                 = "subnet-jumpbox"
  virtual_network_name = local.vnet_name
  resource_group_name  = local.rg_name
}

data "azurerm_subnet" "aks" {
  name                 = "subnet-aks"
  virtual_network_name = local.vnet_name
  source_group_name    = local.rg_name
}

data "azurerm_subnet" "gateway" {
  name                 = "subnet-gateway"
  virtual_network_name = local.vnet_name
  resource_group_name  = local.rg_name
}

# Outputs

output "jumpbox_subnet_id" {
  value = data.azurerm_subnet.jumpbox.id
}

output "aks_subnet_id" {
  value = data.azurerm_subnet.aks.id
}

output "gateway_subnet_id" {
  value = data.azurerm_subnet.gateway.id
}