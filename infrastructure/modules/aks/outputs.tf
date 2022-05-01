output "agw_public_ip_address" {
  value = data.azurerm_public_ip.default.ip_address
}

output "principal_id" {
  value = azurerm_kubernetes_cluster.default.identity[0].principal_id
}
