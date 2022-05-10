terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
  }
  backend "local" {
    path = "./.workspace/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}

locals {
  main_tags     = { Instance = "Main" }
  failover_tags = { Instance = "Failover" }
}


module "network_main" {
  source              = "../azure/network"
  location            = var.main_location
  environment         = var.environment
  instance            = var.main_instance
  jumbbox_vm_password = var.jumbbox_vm_password
  tags                = local.main_tags
}

# module "network_failover" {
#   source      = "./network"
#   location    = var.failover_location
#   environment = var.environment
#   instance    = var.failover_instance
#   tags        = local.failover_tags
# }
