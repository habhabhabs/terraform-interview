terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "this" {
  name     = "alex-interview-terraform"
  location = "Southeast Asia"
}

resource "random_password" "mongodb" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}