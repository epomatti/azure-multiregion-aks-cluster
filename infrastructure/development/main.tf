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
  root_name = "${var.application_name}-${var.environment}-${var.instance}"
  tags      = { Instance = "Development" }
}


module "rg" {
  source    = "../modules/group"
  root_name = local.root_name
  location  = var.location
  tags      = local.tags
}

module "cosmos" {
  source              = "../modules/cosmos"
  root_name           = local.root_name
  resource_group_name = module.rg.name
  main_location       = var.location
  failover_location   = var.location
  tags                = local.tags
}

data "azurerm_client_config" "current" {}

module "kv" {
  source                   = "../modules/keyvault"
  root_name                = local.root_name
  resource_group_name      = module.rg.name
  location                 = var.location
  aks_principal_id         = data.azurerm_client_config.current.client_id
  cosmos_connection_string = module.cosmos.primary_connection_tring
  tags                     = local.tags
}

output "keyvault_url" {
  description = "Add this to your development environment configuration."
  value       = module.kv.uri
  sensitive   = false
}
