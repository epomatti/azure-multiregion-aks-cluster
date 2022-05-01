output "agw_public_ip_address" {
  value = data.azurerm_public_ip.default.ip_address
}
