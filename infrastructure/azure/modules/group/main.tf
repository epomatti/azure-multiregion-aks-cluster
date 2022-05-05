resource "azurerm_resource_group" "default" {
  name     = "rg-${var.root_name}"
  location = var.location

  tags = var.tags
}
