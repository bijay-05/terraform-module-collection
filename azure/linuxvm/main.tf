resource "azurerm_linux_virtual_machine" "testvm" {
  name                = var.vm_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    var.nic_id,
  ]

  # custom_data = filebase64("./customdata.tftpl")

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("/path/to/public/ssh-key")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}