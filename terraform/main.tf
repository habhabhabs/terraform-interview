data "azurerm_client_config" "current" {}

# host persistent docker container storages
resource "azurerm_storage_account" "this" {
  name                     = "alexinterviewstorage"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "mongo-data" {
  name                 = "mongo-data"
  storage_account_name = azurerm_storage_account.this.name
  quota                = 50 # in GB
}

# group of containers - lamp stack
resource "azurerm_container_group" "this" {
  name                = "alex-interview-lampstack"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "mongodb"
    image  = "mongo:latest"
    cpu    = "2"
    memory = "16"

    ports {
      port     = 27017
      protocol = "TCP"
    }

    volume {
      name = "mongo-data"
      mount_path = "/data/db"
      share_name = azurerm_storage_share.mongo-data.name
      storage_account_name = azurerm_storage_account.this.name
      storage_account_key = azurerm_storage_account.this.primary_access_key
    }

    secure_environment_variables = {
      MONGO_INITDB_ROOT_USERNAME = "admin"
      MONGO_INITDB_ROOT_PASSWORD = random_password.mongodb.result
    }
  }

  container {
    name   = "mongodb-express"
    image  = "mongo-express:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8081
      protocol = "TCP"
    }

    secure_environment_variables = {
      ME_CONFIG_MONGODB_ADMINUSERNAME = "admin"
      ME_CONFIG_MONGODB_ADMINPASSWORD = random_password.mongodb.result
      ME_CONFIG_MONGODB_SERVER = "mongodb://admin:${random_password.mongodb.result}@localhost:27017"
    }

    # volume
  }

  tags = {
    environment = "testing"
  }
}