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
  global_root_name   = "${var.application_name}-${var.environment}-global"
  main_root_name     = "${var.application_name}-${var.environment}${var.main_instance}"
  failover_root_name = "${var.application_name}-${var.environment}${var.failover_instance}"

  global_location = var.main_location

  global_tags   = { Instance = "Global" }
  main_tags     = { Instance = "Main" }
  failover_tags = { Instance = "Failover" }
}

### Networking Setup 

module "network_main" {
  source      = "./network"
  location    = var.main_location
  environment = var.environment
  instance    = var.main_instance
  tags        = local.main_tags
}

### Global Setup

module "rg_global" {
  source    = "./modules/group"
  root_name = local.global_root_name
  location  = local.global_location
  tags      = local.global_tags
}

module "cosmos" {
  source                 = "./modules/cosmos"
  root_name              = local.global_root_name
  resource_group_name    = module.rg_global.name
  aks_main_subnet_id     = module.network_main.aks_subnet_id
  main_location          = var.main_location
  failover_location      = var.failover_location
  jumpbox_main_subnet_id = module.network_main.jumpbox_subnet_id
  tags                   = local.global_tags
}

### Workload

module "workload_main" {
  source                          = "./workload"
  application_name                = var.application_name
  location                        = var.main_location
  environment                     = var.environment
  instance                        = var.main_instance
  gateway_subnet_id               = module.network_main.gateway_subnet_id
  aks_subnet_id                   = module.network_main.aks_subnet_id
  jumpbox_subnet_id               = module.network_main.jumpbox_subnet_id
  cosmos_primary_connection_tring = module.cosmos.primary_connection_tring
  aks_vm_size                     = var.aks_vm_size
  aks_node_count                  = var.aks_node_count
  tags                            = local.main_tags
}


### Global Front Door

module "frontdoor" {
  source               = "./modules/frontdoor"
  root_name            = "${var.application_name}${var.environment}"
  resource_group_name  = module.rg_global.name
  main_ingress_address = module.workload_main.agw_public_ip_address
  # failover_ingress_address = module.aks_failover.agw_public_ip_address
  tags = local.main_tags
}




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
