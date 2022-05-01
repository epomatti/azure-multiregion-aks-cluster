resource "azurerm_resource_group" "default" {
  name     = "rg-${var.application_name}-${var.location}"
  location = var.location
}
