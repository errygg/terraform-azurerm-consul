terraform {
  required_version = "~> 0.11"
}

provider "azurerm" {}

resource "azurerm_resource_group" "consul" {
  name     = "${var.namespace}-consul-server"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "consul" {
  name                = "${var.virtual_network_name}"
  address_space       = ["${var.network_space}"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.consul.name}"
}

resource "azurerm_subnet" "consul" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${azurerm_virtual_network.consul.name}"
  resource_group_name  = "${azurerm_resource_group.consul.name}"
  address_prefix       = "${var.consul_subnet}"
}

resource "azurerm_public_ip" "consul" {
  name                = "${var.public_ip_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.consul.name}"
  allocation_method   = "Static" # Case Sensitive
}

resource "azurerm_network_security_group" "consul" {
  name                = "consul-network-security-group"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.consul.name}"
}

resource "azurerm_network_security_rule" "consul_ssh" {
  name                        = "consul-ssh-nsg-rule"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  priority                    = 100
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "http" {
  name                        = "consul-http-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 110
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "https" {
  name                        = "consul-https-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 120
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "server" {
  name                        = "consul-server-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 130
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "8300"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "serf_lan" {
  name                        = "consul-serf-lan-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 140
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "8301"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "serf_wan" {
  name                        = "consul-serf-wan-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 150
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "8302"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "ui" {
  name                        = "consul-ui-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 160
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "8500"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "ui-secure" {
  name                        = "consul-ui-secure-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 170
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "8501"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "dns" {
  name                        = "consul-dns-nsg-rule"
  network_security_group_name = "${azurerm_network_security_group.consul.name}"
  resource_group_name         = "${azurerm_resource_group.consul.name}"
  priority                    = 180
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "8600"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface" "consul" {
  name                      = "consul-network-interface"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.consul.name}"
  network_security_group_id = "${azurerm_network_security_group.consul.id}"

  ip_configuration {
    name                          = "consul-public-ip-configuration"
    subnet_id                     = "${azurerm_subnet.consul.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.consul.id}"
  }
}

resource "azurerm_virtual_machine" "consul" {
  name                             = "consul-virtual-machine"
  location                         = "${var.location}"
  resource_group_name              = "${azurerm_resource_group.consul.name}"
  network_interface_ids            = ["${azurerm_network_interface.consul.id}"]
  vm_size                          = "standard_e4s_v3"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical" # Case Sensitive
    offer     = "UbuntuServer" # Case Sensitive
    sku       = "16.04-LTS" # Case Sensitive
    version   = "latest"
  }

  storage_os_disk {
    name              = "consul-disk-1"
    caching           = "ReadWrite" # Case Sensitive
    create_option     = "fromimage"
    managed_disk_type = "Standard_LRS" # Case Sensitive
    disk_size_gb      = 100
  }

  os_profile {
    computer_name  = "consul"
    admin_username = "ubuntu" # root is not allowed
    admin_password = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${file(var.ssh_key_file)}"
    }
  }
}
