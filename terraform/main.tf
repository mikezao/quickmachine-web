terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app_rg" {
  name     = "${var.app_name}-rg"
  location = "West Europe"
}

# Add Application Insights for logging and diagnostics
resource "azurerm_application_insights" "main" {
  name                = "${var.app_name}-insights"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  application_type    = "web"
}

resource "azurerm_storage_account" "backend_storage" {
  name                     = "${var.app_name}funcsa"
  resource_group_name      = azurerm_resource_group.app_rg.name
  location                 = azurerm_resource_group.app_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "backend" {
  name                = "${var.app_name}-plan"
  resource_group_name = azurerm_resource_group.app_rg.name
  location            = azurerm_resource_group.app_rg.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption Plan
}

resource "azurerm_linux_function_app" "backend" {
  name                       = "${var.app_name}-backend-func"
  resource_group_name        = azurerm_resource_group.app_rg.name
  location                   = azurerm_resource_group.app_rg.location
  storage_account_name       = azurerm_storage_account.backend_storage.name
  storage_account_access_key = azurerm_storage_account.backend_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.backend.id

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  app_settings = {
    "GITLAB_TRIGGER_TOKEN"               = var.gitlab_trigger_token
    "GITLAB_PROJECT_ID"                  = var.gitlab_project_id
    "APPINSIGHTS_INSTRUMENTATIONKEY"   = azurerm_application_insights.main.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    # This setting makes zip deployments much more reliable
    "WEBSITE_RUN_FROM_PACKAGE"           = "1"
  }
}