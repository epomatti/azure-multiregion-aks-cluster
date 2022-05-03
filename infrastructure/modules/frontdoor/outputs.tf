output "host_name" {
  value = azurerm_frontdoor.default.frontend_endpoint[0].host_name
}
