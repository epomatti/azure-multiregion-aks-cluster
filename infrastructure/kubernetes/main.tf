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
  }
}

locals {
  application_name = "openvote555"
  main_location    = "westus"
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "main" {
  name                = "kv-${local.application_name}-${local.main_location}"
  resource_group_name = "rg-${local.application_name}-${local.main_location}"
}

data "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${local.application_name}-${local.main_location}"
  resource_group_name = "rg-${local.application_name}-${local.main_location}"
}


provider "kubernetes" {
  host = data.azurerm_kubernetes_cluster.main.kube_config[0].host

  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_config_map" "default" {
  metadata {
    name = "solution-config"
  }
  data = {
    KEYVAULT_URL = data.azurerm_key_vault.main.vault_uri
  }
}

resource "kubernetes_secret" "default" {
  metadata {
    name = "solution-secrets"
  }
  data = {
    KEYVAULT_URL = data.azurerm_key_vault.main.vault_uri
  }
}
