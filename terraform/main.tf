data "azurerm_client_config" "current" {}

# stateful database
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

# stateless backend-frontend instance
resource "azurerm_container_group" "backend_frontend_primary" {
  name                = "alex-interview-backend-instance-primary"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Private"
  os_type             = "Linux"
  network_profile_id  = azurerm_network_profile.container_vnet_network_profile.id

  container {
    name   = "alex-interview"
    # image  = "habhabhabs/alex-interview:${var.container_version_num}" # for redundancy concept
    image  = "habhabhabs/alex-interview:1.0" # for blue-green deployment concept
    cpu    = "2"
    memory = "16"

    ports {
      port     = 8080
      protocol = "TCP"
    }

    secure_environment_variables = {
      MONGODB_CONN_STRING = azurerm_cosmosdb_account.mongo.connection_strings[0]
    }

    environment_variables = {
      INSTANCE_VALUE = "Primary"
    }
  }

  tags = {
    environment = "testing-primary"
  }
}

resource "azurerm_container_group" "backend_frontend_secondary" {
  name                = "alex-interview-backend-instance-secondary"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Private"
  os_type             = "Linux"
  network_profile_id  = azurerm_network_profile.container_vnet_network_profile.id

  container {
    name   = "alex-interview"
    # image  = "habhabhabs/alex-interview:${var.container_version_num}" # for redundancy concept
    image  = "habhabhabs/alex-interview:2.0" # for blue-green deployment concept
    cpu    = "2"
    memory = "16"

    ports {
      port     = 8080
      protocol = "TCP"
    }

    secure_environment_variables = {
      MONGODB_CONN_STRING = azurerm_cosmosdb_account.mongo.connection_strings[1]
    }

    environment_variables = {
      INSTANCE_VALUE = "Secondary"
    }
  }

  tags = {
    environment = "testing-secondary"
  }
}

#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "alex-interview-appgateway-lb-beap"
  frontend_port_name             = "alex-interview-appgateway-lb-feport"
  frontend_ip_configuration_name = "alex-interview-appgateway-lb-feip"
  http_setting_name              = "alex-interview-appgateway-lb-be-htst"
  listener_name                  = "alex-interview-appgateway-lb-httplstn"
  request_routing_rule_name      = "alex-interview-appgateway-lb-rqrt"
  redirect_configuration_name    = "alex-interview-appgateway-lb-rdrcfg"
}

# load balancer for stateless hosting (failover)
resource "azurerm_application_gateway" "load_balancer" {
  name                = "alex-interview-appgateway-lb"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "alex-interview-appgateway-lb-gateway-ip-configuration"
    subnet_id = azurerm_subnet.container_vnet_lb_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    ip_addresses = [azurerm_container_group.backend_frontend_primary.ip_address, azurerm_container_group.backend_frontend_secondary.ip_address]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 120
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 10
  }
}
