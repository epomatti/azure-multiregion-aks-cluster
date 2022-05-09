
variable "application_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance" {
  type = string
}

variable "tags" {
  type = map(string)
}


locals {
  workload_name                         = "${var.application_name}-${var.environment}${var.instance}"
  aks_namespace                         = "default"
  app_registration_service_account_name = "workload-identity-sa"
}

module "group" {
  source    = "../modules/group"
  root_name = local.workload_name
  location  = var.location
  tags      = var.tags
}

module "nsg" {
  source              = "../modules/nsg"
  resource_group_name = module.group.name
  location            = var.main_location
  app_root            = local.workload_name
  tags                = var.main_tags
}

module "vnet" {
  source              = "../modules/vnet"
  app_root            = local.workload_name
  resource_group_name = module.group.name
  location            = var.location
  nsg_id              = module.nsg.id
  tags                = var.tags
}

module "bastion" {
  source              = "../modules/bastion"
  app_root            = local.workload_name
  resource_group_name = module.group.name
  location            = var.location
  subnet_id           = module.vnet.bastion_subnet_id
  tags                = var.tags
}
