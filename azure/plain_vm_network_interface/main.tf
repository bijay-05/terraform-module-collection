resource "azurerm_network_interface" "testnic" {
  name                = var.nic_name
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.ip_allocation_method
  }

  tags = {
    environment = "dev"
  }
}