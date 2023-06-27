variable "image_id" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "entorno" {
  type = string

  validation {
    condition     = can(regex("^test$|^prod$", var.entorno))
    error_message = "La variable entorno acepta uno de estos valores: \"test\" o \"prod\"."
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.entorno}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "West Europe"
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.entorno}-internal"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.entorno}-vm_public_ip"
  resource_group_name = var.resource_group
  location            = "West Europe"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.entorno}-nic"
  resource_group_name = var.resource_group
  location            = "West Europe"

  ip_configuration {
    name                          = "${var.entorno}-internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "http_nsg"
  location            = "West Europe"
  resource_group_name = var.resource_group

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http_sg"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

output "vm_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group
  location                        = "West Europe"
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  source_image_id                 = var.image_id
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  //provisioner "remote-exec" {
  //  inline = [
  //    "cd /app",
  //    "./API/API &",
  //    "http-server wwwroot/ -p 8080 &"
  //  ]
//
  //  connection {
  //    host = azurerm_public_ip.public_ip.ip_address
  //    user = "adminuser"
  //    type = "ssh"
  //    private_key = "${file("~/.ssh/id_rsa")}"
  //    timeout = "4m"
  //    agent = false
  //  }
  //}
}