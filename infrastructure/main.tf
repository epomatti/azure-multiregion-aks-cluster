terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  main_suffix     = "${var.application_name}-${var.main_location}"
  failover_suffix = "${var.application_name}-${var.failover_location}"
}

### Main Location

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.main_suffix}"
  location = var.main_location
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${local.main_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${local.main_suffix}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.aks_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate

  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw

  sensitive = true
}


### Global Resources

resource "azurerm_resource_group" "global" {
  name     = "rg-${var.application_name}-global"
  location = var.main_location
}

resource "azurerm_frontdoor" "global" {
  name                = "ft-${var.application_name}"
  resource_group_name = azurerm_resource_group.global.name

  routing_rule {
    name               = "nginxRoutingRule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["nginxFrontend"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "nginxBackendPool"
    }
  }

  backend_pool_load_balancing {
    name = "nginxLoadBalancing"
  }

  backend_pool_health_probe {
    name = "nginxHealthProbe"
  }

  backend_pool {
    name = "nginxBackendPool"
    backend {
      host_header = "20.201.0.181"
      address     = "20.201.0.181"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "nginxLoadBalancing"
    health_probe_name   = "nginxHealthProbe"
  }

  frontend_endpoint {
    name      = "nginxFrontend"
    host_name = "ft-${var.application_name}.azurefd.net"
  }
}
