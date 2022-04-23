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

# resource "azurerm_resource_group" "global" {
#   name     = "rg-${application_name}-global"
#   location = var.main_location
# }

# resource "azurerm_frontdoor" "example" {
#   name                = "ft-${application_name}"
#   resource_group_name = azurerm_resource_group.frontdoor.name

#   routing_rule {
#     name               = "exampleRoutingRule1"
#     accepted_protocols = ["Http", "Https"]
#     patterns_to_match  = ["/*"]
#     frontend_endpoints = ["exampleFrontendEndpoint1"]
#     forwarding_configuration {
#       forwarding_protocol = "MatchRequest"
#       backend_pool_name   = "exampleBackendBing"
#     }
#   }

#   backend_pool_load_balancing {
#     name = "exampleLoadBalancingSettings1"
#   }

#   backend_pool_health_probe {
#     name = "exampleHealthProbeSetting1"
#   }

#   backend_pool {
#     name = "exampleBackendBing"
#     backend {
#       host_header = "www.bing.com"
#       address     = "www.bing.com"
#       http_port   = 80
#       https_port  = 443
#     }

#     load_balancing_name = "exampleLoadBalancingSettings1"
#     health_probe_name   = "exampleHealthProbeSetting1"
#   }

#   frontend_endpoint {
#     name      = application_name
#     host_name = "${application_name}.azurefd.net"
#   }
# }
