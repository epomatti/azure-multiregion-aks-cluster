terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.4.0"
    }
  }
  backend "local" {
    path = "./.workspace/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  main_handle     = "${var.application_name}-${var.main_location}"
  failover_handle = "${var.application_name}-${var.failover_location}"
}

### Main Location

module "rg_main" {
  source           = "./modules/group"
  application_name = var.application_name
  location         = var.main_location
}

module "cosmos_main" {
  source              = "./modules/cosmos"
  application_name    = var.application_name
  resource_group_name = module.rg_main.name
  main_location       = var.main_location
  failover_location      = var.failover_location
  enable_free_tier       = var.cosmos_enable_free_tier
  total_throughput_limit = var.cosmos_total_throughput_limit
}

module "log_main" {
  source              = "./modules/log"
  application_name    = var.application_name
  resource_group_name = module.rg_main.name
  location            = var.main_location
}

module "aks_main" {
  source                     = "./modules/aks"
  application_name           = var.application_name
  resource_group_name        = module.rg_main.name
  location                   = var.main_location
  vm_size                    = var.aks_vm_size
  ingress_subnet_cidr        = var.aks_ingress_subnet_cidr
  log_analytics_workspace_id = module.log_main.id
}

module "frontdoor" {
  source                   = "./modules/frontdoor"
  application_name         = var.application_name
  resource_group_name      = module.rg_main.name
  main_ingress_address     = module.aks_main.agw_public_ip_address
  # failover_ingress_address = module.aks_failover.agw_public_ip_address
}

### Failover Location ###

# module "rg_failover" {
#   source           = "./modules/group"
#   application_name = var.application_name
#   location         = var.failover_location
# }

# module "log_failover" {
#   source              = "./modules/log"
#   application_name    = var.application_name
#   resource_group_name = module.rg_failover.name
#   location            = var.failover_location
# }

# module "aks_failover" {
#   source                     = "./modules/aks"
#   application_name           = var.application_name
#   resource_group_name        = module.rg_failover.name
#   location                   = var.failover_location
#   vm_size                    = var.aks_vm_size
#   ingress_subnet_cidr        = var.aks_ingress_subnet_cidr
#   log_analytics_workspace_id = module.log_failover.id
# }

