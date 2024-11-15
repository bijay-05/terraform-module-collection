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
  connection {
      type = "ssh"
      user = var.admin_username
      private_key = file("/path/to/local/private/ssh_keys")
      host = self.public_ip_address
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-scripts.tftpl", {
      hostname     = self.public_ip_address,
      user         = var.admin_username,
      identityfile = "/path/to/local/private/ssh_keys"
    })
    interpreter = ["bash", "-c"]
  }
  provisioner "file" {
    source      = "./nvm-install.sh"
    destination = "setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "bash ~/setup.sh",
      # "source ~/.bashrc" cannot perform this on script
    ]
  }
}