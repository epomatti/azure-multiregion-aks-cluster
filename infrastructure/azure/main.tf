terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.4.0"
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
  main_root_name                        = "${var.application_name}-${var.environment}-${var.main_instance}"
  failover_root_name                    = "${var.application_name}-${var.environment}-${var.failover_instance}"
  main_tags                             = { Instance = "Main" }
  failover_tags                         = { Instance = "Failover" }
  aks_namespace                         = "default"
  app_registration_service_account_name = "workload-identity-sa"
}

### Main Location

module "rg_main" {
  source    = "./modules/group"
  root_name = local.main_root_name
  location  = var.main_location
  tags      = local.main_tags
}

module "cosmos_main" {
  source              = "./modules/cosmos"
  root_name           = local.main_root_name
  resource_group_name = module.rg_main.name
  main_location       = var.main_location
  failover_location   = var.failover_location
  tags                = local.main_tags
}

module "log_main" {
  source              = "./modules/log"
  root_name           = local.main_root_name
  resource_group_name = module.rg_main.name
  location            = var.main_location
  tags                = local.main_tags
}

module "aks_main" {
  source                     = "./modules/aks"
  root_name                  = local.main_root_name
  resource_group_name        = module.rg_main.name
  location                   = var.main_location
  default_namespace          = local.aks_namespace
  vm_size                    = var.aks_vm_size
  node_count                 = var.aks_node_count
  ingress_subnet_cidr        = var.aks_ingress_subnet_cidr
  log_analytics_workspace_id = module.log_main.id
  tags                       = local.main_tags
}

module "app_registration" {
  source               = "./modules/app-registration"
  root_name            = local.main_root_name
  oidc_issuer_url      = module.aks_main.oidc_issuer_url
  aks_namespace        = local.aks_namespace
  service_account_name = local.app_registration_service_account_name
}


module "kv_main" {
  source                          = "./modules/keyvault"
  root_name                       = local.main_root_name
  resource_group_name             = module.rg_main.name
  location                        = var.main_location
  aks_service_principal_object_id = module.app_registration.aks_service_principal_object_id
  cosmos_connection_string        = module.cosmos_main.primary_connection_tring
  tags                            = local.main_tags
}

module "frontdoor" {
  source               = "./modules/frontdoor"
  root_name            = "${var.application_name}-${var.environment}"
  resource_group_name  = module.rg_main.name
  main_ingress_address = module.aks_main.agw_public_ip_address
  # failover_ingress_address = module.aks_failover.agw_public_ip_address
  tags = local.main_tags
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



### Outputs

output "main_resource_group_name" {
  value       = module.rg_main.name
  description = "Set this value as ENV $group to connect to the Kubernetes cluster using kubectl."
}

output "main_aks_name" {
  value       = module.aks_main.name
  description = "Set this value as ENV $aks to connect to the Kubernetes cluster using kubectl."
}

output "main_keyvault_url" {
  value = module.kv_main.url
}

output "main_aks_fqdn" {
  value = module.aks_main.fqdn
}

output "frontdoor_host_name" {
  value = module.frontdoor.host_name
}