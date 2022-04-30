terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
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

resource "azurerm_cosmosdb_account" "main" {
  name                 = "cosmos-${local.main_suffix}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.0"
  enable_free_tier     = true

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  capacity {
    total_throughput_limit = 1000
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "poll" {
  name                = "poll"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_mongo_collection" "polls" {
  name                = "polls"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_mongo_database.poll.name

  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_cosmosdb_mongo_database" "vote" {
  name                = "vote"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_mongo_collection" "votes" {
  name                = "votes"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_mongo_database.vote.name

  index {
    keys   = ["_id"]
    unique = true
  }
}


### Log Analytics

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.main_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


### Kubernetes ###

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

  ingress_application_gateway {
    gateway_name = "agw-${local.main_suffix}"
    subnet_cidr  = "10.225.0.0/16"
  }

  # microsoft_defender {
  #   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  # }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  # network_profile {
  #   network_plugin = "azure"
  # }

  identity {
    type = "SystemAssigned"
  }

}


resource "azurerm_monitor_diagnostic_setting" "application_gateway" {
  name                       = "Application Gateway Logs"
  target_resource_id         = azurerm_kubernetes_cluster.main.ingress_application_gateway[0].effective_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

}




### Outputs

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate

  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw

  sensitive = true
}

output "kube_fqdn" {
  value = azurerm_kubernetes_cluster.main.fqdn

  sensitive = false
}



### Global Resources

# resource "azurerm_resource_group" "global" {
#   name     = "rg-${var.application_name}-global"
#   location = var.main_location
# }

# resource "azurerm_frontdoor" "global" {
#   name                = "ft-${var.application_name}"
#   resource_group_name = azurerm_resource_group.global.name

#   routing_rule {
#     name               = "nginxRoutingRule"
#     accepted_protocols = ["Http", "Https"]
#     patterns_to_match  = ["/*"]
#     frontend_endpoints = ["nginxFrontend"]
#     forwarding_configuration {
#       forwarding_protocol = "MatchRequest"
#       backend_pool_name   = "nginxBackendPool"
#     }
#   }

#   backend_pool_load_balancing {
#     name = "nginxLoadBalancing"
#   }

#   backend_pool_health_probe {
#     name = "nginxHealthProbe"
#   }

#   backend_pool {
#     name = "nginxBackendPool"
#     backend {
#       host_header = "20.201.0.181"
#       address     = "20.201.0.181"
#       http_port   = 80
#       https_port  = 443
#     }

#     load_balancing_name = "nginxLoadBalancing"
#     health_probe_name   = "nginxHealthProbe"
#   }

#   frontend_endpoint {
#     name      = "nginxFrontend"
#     host_name = "ft-${var.application_name}.azurefd.net"
#   }
# }

# resource "azurerm_log_analytics_workspace" "default" {
#   name                = "log${random_integer.ri.result}"
#   location            = azurerm_resource_group.default.location
#   resource_group_name = azurerm_resource_group.default.name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
# }

# resource "azurerm_monitor_diagnostic_setting" "default" {
#   name                       = "Python API Application Logs"
#   target_resource_id         = azurerm_linux_web_app.default.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id

#   log {
#     category = "AppServiceConsoleLogs"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }

#   log {
#     category = "AppServiceAppLogs"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }

#   log {
#     category = "AppServiceHTTPLogs"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
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
