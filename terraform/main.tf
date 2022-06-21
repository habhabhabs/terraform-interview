# host persistent docker container storages
resource "azurerm_storage_account" "this" {
  name                     = "alexinterviewstorage"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "this" {
  name                 = "docker-container-share"
  storage_account_name = azurerm_storage_account.this.name
  quota                = 50 # in GB
}

# group of containers - lamp stack
resource "azurerm_container_group" "this" {
  name                = "example-continst"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Private"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    volume {
      name = "hello-world-volume"
      mount_path = "/hello-world-volume/"
      share_name = azurerm_storage_share.this.name
      storage_account_name = azurerm_storage_account.this.name
      storage_account_key = azurerm_storage_account.this.primary_access_key
    }

  }

  container {
    name   = "sidecar"
    image  = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
    cpu    = "0.5"
    memory = "1.5"

    # volume
  }

  tags = {
    environment = "testing"
  }
}