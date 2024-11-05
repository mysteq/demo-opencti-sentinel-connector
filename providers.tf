terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstatedemosentconn"
    storage_account_name = "tfstatesent54135"
    container_name       = "tfstatesent"
    key                  = "tfstatesent.tfstate"
    subscription_id      = "ad3a592d-2f32-4013-8b6a-a290a0aafed2"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "49a743cb-1b0b-4bbd-9986-f9fcf513526f"
}

provider "azapi" {
  subscription_id = "49a743cb-1b0b-4bbd-9986-f9fcf513526f"
}