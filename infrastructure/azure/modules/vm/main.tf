resource "azurerm_network_interface" "main" {
  name                = "nic-jumpbox-${var.workload_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "subnet-config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_virtual_machine" "main" {
  name                  = "vm-jumpbox-${var.workload_name}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202205060"
  }

  storage_os_disk {
    name              = "disk-jumpbox-${var.workload_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "jumpbox"
    admin_username = "azadm"
    admin_password = var.password
    custom_data    = filebase64("${path.module}/tools.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags

}
