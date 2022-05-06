resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.app_root}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/8"]
  # dns_servers         = []

  tags = var.tags
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.10.0.0/24"]
  service_endpoints    = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "aks" {
  name                 = "subnet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.90.0.0/16"]
  service_endpoints    = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "cosmos" {
  name                 = "subnet-cosmos"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.10.10.0/24"]
}

resource "azurerm_subnet" "keyvault" {
  name                 = "subnet-keyvault"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.10.20.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "subnet-bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "subnet-aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "subnet-cosmos" {
  subnet_id                 = azurerm_subnet.cosmos.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "subnet-keyvault" {
  subnet_id                 = azurerm_subnet.keyvault.id
  network_security_group_id = var.nsg_id
}
