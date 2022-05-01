resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-${local.application_name}-${location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "aks-${var.application_name}"
  node_resource_group = "rg-${var.application_name}-k8s-${var.location}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.vm_size
  }

  ingress_application_gateway {
    gateway_name = "agw-${local.application_name}"
    subnet_cidr  = var.ingress_subnet_cidr
  }

  # microsoft_defender {
  #   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  # }

  # network_profile {
  #   network_plugin = "azure"
  # }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  identity {
    type = "SystemAssigned"
  }

}


resource "azurerm_monitor_diagnostic_setting" "application_gateway" {
  name                       = "Application Gateway Logs"
  target_resource_id         = azurerm_kubernetes_cluster.default.ingress_application_gateway[0].effective_gateway_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

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

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

}

data "azurerm_public_ip" "default" {
  name                = "agw-${var.application_name}-${var.location}-appgwpip"
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_kubernetes_cluster.default
  ]
}
