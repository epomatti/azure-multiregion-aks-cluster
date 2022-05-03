terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
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
  main_root_name           = "${var.application_name}-${var.environment}-${var.main_instance}"
  main_resource_group_name = "rg-${local.main_root_name}"
  # failover_root_name = "${var.application_name}-${var.environment}-${var.failover_instance}"
  # failover_resource_group_name = "rg-${failover_root_name}"
}

data "azurerm_client_config" "current" {}


data "azurerm_key_vault" "main" {
  name                = "kv-${local.main_root_name}"
  resource_group_name = local.main_resource_group_name
}

data "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${local.main_root_name}"
  resource_group_name = local.main_resource_group_name
}


provider "kubernetes" {
  host = data.azurerm_kubernetes_cluster.main.kube_config[0].host

  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_config_map" "default" {
  metadata {
    name = "solution-configmap"
  }
  data = {
    USE_KEYVAULT = true
    KEYVAULT_URL = data.azurerm_key_vault.main.vault_uri
  }
}
