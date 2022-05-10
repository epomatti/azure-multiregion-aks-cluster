locals {
  root_name = "network-${var.environment}-${var.instance}"
}

module "group" {
  source    = "../modules/group"
  root_name = local.root_name
  location  = var.location
  tags      = var.tags
}

module "nsg" {
  source              = "../modules/nsg"
  resource_group_name = module.group.name
  location            = var.location
  app_root            = local.root_name
  tags                = var.tags
}

module "vnet" {
  source              = "../modules/vnet"
  app_root            = local.root_name
  resource_group_name = module.group.name
  location            = var.location
  nsg_id              = module.nsg.id
  tags                = var.tags
}

module "bastion" {
  source              = "../modules/bastion"
  app_root            = local.root_name
  resource_group_name = module.group.name
  location            = var.location
  subnet_id           = module.vnet.bastion_subnet_id
  tags                = var.tags
}

module "jumpbox" {
  source              = "../modules/vm"
  workload_name       = local.root_name
  resource_group_name = module.group.name
  location            = var.location
  subnet_id           = module.vnet.jumpbox_subnet_id
  password            = var.jumbbox_vm_password
  tags                = var.tags
}
