resource "azurerm_frontdoor" "default" {
  name                = "ft-${var.root_name}"
  resource_group_name = var.resource_group_name

  routing_rule {
    name               = "Main-IngressRoutingRule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["IngressFrontend"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "Main-IngressBackendPool"
    }
  }

  backend_pool_load_balancing {
    name = "Main-IngressLoadBalancing"
  }

  backend_pool_health_probe {
    name = "Main-IngressHealthProbe"
  }

  backend_pool {
    name = "Main-IngressBackendPool"
    backend {
      host_header = var.main_ingress_address
      address     = var.main_ingress_address
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "Main-IngressLoadBalancing"
    health_probe_name   = "Main-IngressHealthProbe"
  }

  backend_pool_settings {
    backend_pools_send_receive_timeout_seconds   = 0
    enforce_backend_pools_certificate_name_check = false
  }

  frontend_endpoint {
    name      = "IngressFrontend"
    host_name = "ft-${var.root_name}.azurefd.net"
  }

  tags = var.tags

}
