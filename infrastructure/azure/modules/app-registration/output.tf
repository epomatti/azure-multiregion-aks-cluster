output "aks_service_principal_object_id" {
  value = azuread_service_principal.default.object_id
  description = "This value is used to create the Key Vault Access Policy."
}
