data "azurerm_client_config" "current" {}

# database
resource "azurerm_cosmosdb_account" "mongo" {
  name                = "alex-interview-mongo"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "Central US"
    failover_priority = 1
  }

  geo_location {
    location          = "East US"
    failover_priority = 0
  }
}

# group of containers - lamp stack
resource "azurerm_container_group" "this_backend_frontend" {
  name                = "alex-interview-backend-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Private"
  os_type             = "Linux"
  count               = 2

  container {
    name   = "alex-interview"
    image  = "habhabhabs/alex-interview:${var.container_version_num}"
    cpu    = "2"
    memory = "16"

    ports {
      port     = 80
      protocol = "TCP"
    }

    secure_environment_variables = {
      MONGODB_CONN_STRING = azurerm_cosmosdb_account.mongo.connection_strings[0]
    }
  }

  tags = {
    environment = "testing"
  }
}

