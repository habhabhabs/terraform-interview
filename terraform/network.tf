resource "azurerm_public_ip" "lb" {
  name                = "alex-interview-lb-public-ip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


# private network - container
resource "azurerm_virtual_network" "container_vnet" {
  name                = "alex-interview-container-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "container_vnet_subnet" {
  name                 = "alex-interview-container-vnet-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.container_vnet.name
  address_prefixes     = ["10.1.0.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "container_vnet_lb_subnet" {
  name                 = "alex-interview-container-vnet-lb-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.container_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_profile" "container_vnet_network_profile" {
  name                = "alex-interview-container-vnet-network-profile"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  container_network_interface {
    name = "alex-interview-container-vnet-network-profile-nic"

    ip_configuration {
      name      = "alex-interview-container-vnet-network-profile-ip-configuration"
      subnet_id = azurerm_subnet.container_vnet_subnet.id
    }
  }
}