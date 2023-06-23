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
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = "West Europe"
  resource_group_name = "herramientas_devops"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "herramientas_devops"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "vm_public_ip"
  resource_group_name = "herramientas_devops"
  location            = "West Europe"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "test-nic"
  resource_group_name = "herramientas_devops"
  location            = "West Europe"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "http_nsg"
  location            = "West Europe"
  resource_group_name = "herramientas_devops"

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
  name                            = "test"
  resource_group_name             = "herramientas_devops"
  location                        = "West Europe"
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  source_image_id                 = "/subscriptions/e1cbb5fb-3c9e-46ef-b7e0-a89cbc553e39/resourceGroups/herramientas_devops/providers/Microsoft.Compute/images/despliegue_tfm_1687042124"
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