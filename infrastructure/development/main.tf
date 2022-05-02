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

### Main Location

module "rg_main" {
  source           = "../modules/group"
  application_name = var.application_name
  location         = var.main_location
}

module "cosmos_main" {
  source                 = "./modules/cosmos"
  application_name       = var.application_name
  resource_group_name    = module.rg_main.name
  main_location          = var.main_location
  failover_location      = var.failover_location
  enable_free_tier       = var.cosmos_enable_free_tier
  total_throughput_limit = var.cosmos_total_throughput_limit
}

module "kv_main" {
  source                   = "./modules/keyvault"
  application_name         = var.application_name
  resource_group_name      = module.rg_main.name
  location                 = var.main_location
  aks_principal_id         = module.aks_main.principal_id
  cosmos_connection_string = module.cosmos_main.primary_connection_tring
}

output "keyvault_main_uri" {
  value = module.kv_main.uri
}
