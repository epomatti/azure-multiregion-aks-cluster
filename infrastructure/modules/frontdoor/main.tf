resource "azurerm_frontdoor" "default" {
  name                = "ft-${var.application_name}"
  resource_group_name = var.resource_group_name

  routing_rule {
    name               = "IngressRoutingRule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["IngressFrontend"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "IngressBackendPool"
    }
  }

  backend_pool_load_balancing {
    name = "IngressLoadBalancing"
  }

  backend_pool_health_probe {
    name = "IngressHealthProbe"
  }

  backend_pool {
    name = "IngressBackendPool"
    backend {
      host_header = var.ingress_address
      address     = var.ingress_address
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "IngressLoadBalancing"
    health_probe_name   = "IngressHealthProbe"
  }

  frontend_endpoint {
    name      = "IngressFrontend"
    host_name = "ft-${var.application_name}.azurefd.net"
  }

}
