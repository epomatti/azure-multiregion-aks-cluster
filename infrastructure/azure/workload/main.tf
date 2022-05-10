
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

variable "gateway_subnet_id" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "jumpbox_subnet_id" {
  type = string
}

variable "backup_jumpbox_subnet_id" {
  type = string
}

variable "cosmos_primary_connection_tring" {
  type      = string
  sensitive = true
}

variable "aks_vm_size" {
  type = string
}

variable "aks_node_count" {
  type = number
}

variable "tags" {
  type = map(string)
}


locals {
  workload_name                         = "${var.application_name}-${var.environment}-${var.instance}"
  aks_namespace                         = "default"
  app_registration_service_account_name = "workload-identity-sa"
}

module "group" {
  source    = "../modules/group"
  root_name = local.workload_name
  location  = var.location
  tags      = var.tags
}

module "log" {
  source              = "../modules/log"
  root_name           = local.workload_name
  resource_group_name = module.group.name
  location            = var.location
  tags                = var.tags
}

module "aks" {
  source              = "../modules/aks"
  root_name           = local.workload_name
  resource_group_name = module.group.name
  location            = var.location

  default_namespace = local.aks_namespace
  vm_size           = var.aks_vm_size
  node_count        = var.aks_node_count

  aks_subnet_id     = var.aks_subnet_id
  gateway_subnet_id = var.gateway_subnet_id

  log_analytics_workspace_id = module.log.id

  tags = var.tags
}

module "app_registration" {
  source               = "../modules/app-registration"
  root_name            = local.workload_name
  oidc_issuer_url      = module.aks.oidc_issuer_url
  aks_namespace        = local.aks_namespace
  service_account_name = local.app_registration_service_account_name
}


module "kv" {
  source                          = "../modules/keyvault"
  root_name                       = local.workload_name
  resource_group_name             = module.group.name
  location                        = var.location
  aks_subnet_id                   = var.aks_subnet_id
  jumpbox_subnet_id               = var.jumpbox_subnet_id
  backup_jumpbox_subnet_id        = var.backup_jumpbox_subnet_id
  aks_service_principal_object_id = module.app_registration.aks_service_principal_object_id
  cosmos_connection_string        = var.cosmos_primary_connection_tring
  tags                            = var.tags
}
