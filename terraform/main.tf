terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_test" {
  name     = "RG-Test"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "myappserviceplan"
  location            = azurerm_resource_group.rg_test.location
  resource_group_name = azurerm_resource_group.rg_test.name

  sku {
    tier = "Free"   # Set to Free tier
    size = "F1"     # Free tier size
  }
  
  reserved = true
  kind = "Linux"
}

resource "azurerm_linux_web_app" "web_app" {
	name                = "test-smart-inventory-manager-0123"
	location            = azurerm_resource_group.rg_test.location
	resource_group_name = azurerm_resource_group.rg_test.name
	service_plan_id     = azurerm_app_service_plan.app_service_plan.id
	https_only = true
	site_config {
		application_stack {
			dotnet_version = "8.0"
		}
		minimum_tls_version = "1.2"
		always_on = false
	}
	app_settings = {
		"ASPNETCORE_ENVIRONMENT" = "Testing"
	}
}

resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccount12345400"
  resource_group_name      = azurerm_resource_group.rg_test.name
  location                 = azurerm_resource_group.rg_test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "my_container" {
	name = "mycontainer"
	storage_account_name  = azurerm_storage_account.storage.name
	container_access_type = "private" 
}