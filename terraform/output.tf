output "mongodb_conn_string" {
  value     = azurerm_cosmosdb_account.mongo.connection_strings
  sensitive = true
}

output "mongodb_endpoint" {
  value     = azurerm_cosmosdb_account.mongo.endpoint
  sensitive = true
}

output "appgateway_lb_endpoint" {
  value = azurerm_public_ip.lb.ip_address
}