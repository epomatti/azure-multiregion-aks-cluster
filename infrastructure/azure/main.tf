terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.22.0"
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

provider "azuread" {}

locals {
  global_root_name   = "${var.application_name}-${var.environment}"
  main_root_name     = "${var.application_name}-${var.environment}${var.main_instance}"
  failover_root_name = "${var.application_name}-${var.environment}${var.failover_instance}"

  global_location = var.main_location

  global_tags   = { Instance = "Global" }
  main_tags     = { Instance = "Main" }
  failover_tags = { Instance = "Failover" }
}

### Main Location

module "network_main" {
  source      = "./network"
  location    = var.main_location
  environment = var.environment
  instance    = var.main_instance
  tags        = local.main_tags
}

### Global Resources

module "rg_global" {
  source    = "./modules/group"
  root_name = local.global_root_name
  location  = local.global_location
  tags      = local.global_tags
}

module "cosmos" {
  source              = "./modules/cosmos"
  root_name           = local.global_root_name
  resource_group_name = module.rg_global.name
  aks_main_subnet_id  = module.network_main.aks_subnet_id
  main_location       = var.main_location
  failover_location   = var.failover_location
  tags                = local.main_tags
}

# module "workload_main" {

# }



# module "log_main" {
#   source              = "./modules/log"
#   root_name           = local.main_root_name
#   resource_group_name = module.rg_main.name
#   location            = var.main_location
#   tags                = local.main_tags
# }

# module "aks_main" {
#   source              = "./modules/aks"
#   root_name           = local.main_root_name
#   resource_group_name = module.rg_main.name
#   location            = var.main_location

#   default_namespace = local.aks_namespace
#   vm_size           = var.aks_vm_size
#   node_count        = var.aks_node_count

#   vnet_subnet_id = module.vnet_main.aks_subnet_id
#   # ingress_subnet_cidr = var.aks_ingress_subnet_cidr
#   ingress_subnet_cidr = "10.1.0.0/16"

#   log_analytics_workspace_id = module.log_main.id

#   tags = local.main_tags
# }

# module "app_registration" {
#   source               = "./modules/app-registration"
#   root_name            = local.main_root_name
#   oidc_issuer_url      = module.aks_main.oidc_issuer_url
#   aks_namespace        = local.aks_namespace
#   service_account_name = local.app_registration_service_account_name
# }


# module "kv_main" {
#   source                          = "./modules/keyvault"
#   root_name                       = local.main_root_name
#   resource_group_name             = module.rg_main.name
#   location                        = var.main_location
#   aks_subnet_id                   = module.vnet_main.aks_subnet_id
#   bastion_subnet_id               = module.vnet_main.bastion_subnet_id
#   aks_service_principal_object_id = module.app_registration.aks_service_principal_object_id
#   cosmos_connection_string        = module.cosmos_main.primary_connection_tring
#   tags                            = local.main_tags
# }

# module "frontdoor" {
#   source               = "./modules/frontdoor"
#   root_name            = "${var.application_name}${var.environment}"
#   resource_group_name  = module.rg_main.name
#   main_ingress_address = module.aks_main.agw_public_ip_address
#   # failover_ingress_address = module.aks_failover.agw_public_ip_address
#   tags = local.main_tags
# }

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



### Outputs

# output "bastion_public_ip" {
#   value = module.bastion_main.public_ip
# }

# output "main_keyvault_url" {
#   value = module.kv_main.url
# }

# output "main_aks_fqdn" {
#   value = module.aks_main.fqdn
# }

# output "frontdoor_host_name" {
#   value = module.frontdoor.host_name
# }
