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
  main_handle     = "${var.application_name}-${var.main_location}"
  failover_handle = "${var.application_name}-${var.failover_location}"
}

### Main Location

module "rg_main" {
  source           = "./modules/group"
  application_name = var.application_name
  location         = var.main_location
}

module "cosmos_main" {
  source              = "./modules/cosmos"
  application_name    = var.application_name
  resource_group_name = module.rg_main.name
  main_location       = var.main_location
  # failover_location      = var.failover_location
  enable_free_tier       = var.cosmos_enable_free_tier
  total_throughput_limit = var.cosmos_total_throughput_limit
}

module "log_main" {
  source              = "./modules/log"
  application_name    = var.application_name
  resource_group_name = module.rg_main.name
  location            = var.main_location
}

module "aks_main" {
  source                     = "./modules/aks"
  application_name           = var.application_name
  resource_group_name        = module.rg_main.name
  location                   = var.main_location
  vm_size                    = var.aks_vm_size
  ingress_subnet_cidr        = var.aks_ingress_subnet_cidr
  log_analytics_workspace_id = module.log_main.id
}

module "frontdoor" {
  source               = "./modules/frontdoor"
  application_name     = var.application_name
  resource_group_name  = module.rg_main.name
  main_ingress_address = module.aks_main.agw_public_ip_address
}


# resource "azurerm_resource_group" "main" {
#   name     = "rg-${local.main_suffix}"
#   location = var.main_location
# }

# resource "azurerm_cosmosdb_account" "main" {
#   name                 = "cosmos-${local.main_suffix}"
#   location             = azurerm_resource_group.main.location
#   resource_group_name  = azurerm_resource_group.main.name
#   offer_type           = "Standard"
#   kind                 = "MongoDB"
#   mongo_server_version = "4.0"
#   enable_free_tier     = true

#   capabilities {
#     name = "EnableMongo"
#   }

#   consistency_policy {
#     consistency_level = "Session"
#   }

#   capacity {
#     total_throughput_limit = 1000
#   }

#   geo_location {
#     location          = azurerm_resource_group.main.location
#     failover_priority = 0
#   }
# }

# resource "azurerm_cosmosdb_mongo_database" "poll" {
#   name                = "poll"
#   resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
#   account_name        = azurerm_cosmosdb_account.main.name
# }

# resource "azurerm_cosmosdb_mongo_collection" "polls" {
#   name                = "polls"
#   resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
#   account_name        = azurerm_cosmosdb_account.main.name
#   database_name       = azurerm_cosmosdb_mongo_database.poll.name

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }

# resource "azurerm_cosmosdb_mongo_database" "vote" {
#   name                = "vote"
#   resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
#   account_name        = azurerm_cosmosdb_account.main.name
# }

# resource "azurerm_cosmosdb_mongo_collection" "votes" {
#   name                = "votes"
#   resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
#   account_name        = azurerm_cosmosdb_account.main.name
#   database_name       = azurerm_cosmosdb_mongo_database.vote.name

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }


### Log Analytics

# resource "azurerm_log_analytics_workspace" "main" {
#   name                = "log-${local.main_suffix}"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
# }


### Kubernetes ###

# resource "azurerm_kubernetes_cluster" "main" {
#   name                = "aks-${local.main_suffix}"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   dns_prefix          = "aks-${local.main_suffix}"
#   node_resource_group = "rg-${var.application_name}-k8s-${var.main_location}"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = var.aks_vm_size
#   }

#   ingress_application_gateway {
#     gateway_name = "agw-${local.main_suffix}"
#     subnet_cidr  = "10.225.0.0/16"
#   }

#   # microsoft_defender {
#   #   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
#   # }

#   oms_agent {
#     log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
#   }

#   # network_profile {
#   #   network_plugin = "azure"
#   # }

#   identity {
#     type = "SystemAssigned"
#   }

# }


# resource "azurerm_monitor_diagnostic_setting" "application_gateway" {
#   name                       = "Application Gateway Logs"
#   target_resource_id         = azurerm_kubernetes_cluster.main.ingress_application_gateway[0].effective_gateway_id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

#   log {
#     category = "ApplicationGatewayAccessLog"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }

#   log {
#     category = "ApplicationGatewayPerformanceLog"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }

#   log {
#     category = "ApplicationGatewayFirewallLog"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }

# }

# data "azurerm_public_ip" "main" {
#   name                = "agw-${local.main_suffix}-appgwpip"
#   resource_group_name = azurerm_kubernetes_cluster.main.node_resource_group

#   # depends_on = [
#   #   azurerm_kubernetes_cluster.main
#   # ]
# }

# output "gateway_public_ip" {
#   value     = data.azurerm_public_ip.main.ip_address
#   sensitive = false
# }


# data "azurerm_application_gateway" "main" {
#   name                = "agw-${local.main_suffix}"
#   resource_group_name = azurerm_kubernetes_cluster.main.node_resource_group

#   depends_on = [
#     azurerm_kubernetes_cluster.main
#   ]
# }


### Outputs

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate

#   sensitive = true
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.main.kube_config_raw

#   sensitive = true
# }

# output "kube_fqdn" {
#   value = azurerm_kubernetes_cluster.main.fqdn

#   sensitive = false
# }


### Global Resources

# resource "azurerm_resource_group" "global" {
#   name     = "rg-${var.application_name}-global"
#   location = var.main_location
# }

# resource "azurerm_frontdoor" "global" {
#   name                = "ft-${var.application_name}"
#   resource_group_name = azurerm_resource_group.global.name

#   routing_rule {
#     name               = "IngressRoutingRule"
#     accepted_protocols = ["Http", "Https"]
#     patterns_to_match  = ["/*"]
#     frontend_endpoints = ["IngressFrontend"]
#     forwarding_configuration {
#       forwarding_protocol = "MatchRequest"
#       backend_pool_name   = "IngressBackendPool"
#     }
#   }

#   backend_pool_load_balancing {
#     name = "IngressLoadBalancing"
#   }

#   backend_pool_health_probe {
#     name = "IngressHealthProbe"
#   }

#   backend_pool {
#     name = "IngressBackendPool"
#     backend {
#       host_header = data.azurerm_public_ip.main.ip_address
#       address     = data.azurerm_public_ip.main.ip_address
#       http_port   = 80
#       https_port  = 443
#     }

#     load_balancing_name = "IngressLoadBalancing"
#     health_probe_name   = "IngressHealthProbe"
#   }

#   frontend_endpoint {
#     name      = "IngressFrontend"
#     host_name = "ft-${var.application_name}.azurefd.net"
#   }

# }




# resource "azurerm_key_vault" "example" {
#   name                        = "examplekeyvault"
#   location                    = azurerm_resource_group.example.location
#   resource_group_name         = azurerm_resource_group.example.name
#   enabled_for_disk_encryption = true
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false

#   sku_name = "standard"

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "Get",
#     ]

#     secret_permissions = [
#       "Get",
#     ]

#     storage_permissions = [
#       "Get",
#     ]
#   }
# }
