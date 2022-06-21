output "mongodb_conn_string" {
  value     = azurerm_cosmosdb_account.mongo.connection_strings
  sensitive = true
}

output "mongodb_endpoint" {
  value     = azurerm_cosmosdb_account.mongo.endpoint
  sensitive = true
}