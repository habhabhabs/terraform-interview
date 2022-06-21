terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "this" {
  name     = "alex-interview-terraform"
  location = "Southeast Asia"
}
