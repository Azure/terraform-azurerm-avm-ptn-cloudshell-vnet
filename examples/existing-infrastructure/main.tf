terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

# =========================================
# Create "Existing" Infrastructure for Demo
# =========================================
# This example demonstrates using the module with existing infrastructure
# In a real scenario, these resources would already exist

## Section to provide a random Azure region
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region

# Naming module for unique names
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# Create "existing" Resource Group (simulating pre-existing infrastructure)
resource "azurerm_resource_group" "existing" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = "${module.naming.resource_group.name_unique}-existing"
}

# Create "existing" Virtual Network (simulating pre-existing infrastructure)
resource "azurerm_virtual_network" "existing" {
  location            = azurerm_resource_group.existing.location
  name                = "${module.naming.virtual_network.name_unique}-existing"
  resource_group_name = azurerm_resource_group.existing.name
  address_space       = ["10.0.0.0/16"]
}

# Generate unique suffix for storage and relay names
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  numeric = true
  special = false
  upper   = false
}

# =========================================
# Data Sources - Reference "Existing" Resources
# =========================================
# In a real scenario, you would use data sources to reference
# truly existing resources instead of creating them above

data "azurerm_resource_group" "existing" {
  name = azurerm_resource_group.existing.name

  depends_on = [azurerm_resource_group.existing]
}

data "azurerm_virtual_network" "existing" {
  name                = azurerm_virtual_network.existing.name
  resource_group_name = azurerm_resource_group.existing.name

  depends_on = [azurerm_virtual_network.existing]
}

# =========================================
# CloudShell VNet Module
# =========================================

# Deploy CloudShell with "existing" VNet
# This demonstrates the data source pattern for referencing existing infrastructure
module "cloudshell_vnet" {
  source = "../../"

  # Subnet Configuration
  # These address ranges are available within the 10.0.0.0/16 VNet created above
  container_subnet_address_prefix = "10.0.1.0/28"
  # Relay Namespace Configuration (unique name required)
  relay_namespace_name        = "cloudshell-relay-${random_string.suffix.result}"
  relay_subnet_address_prefix = "10.0.1.16/28"
  # Storage Account Configuration (unique names required)
  storage_account_name          = "cloudshell${random_string.suffix.result}"
  storage_subnet_address_prefix = "10.0.1.32/28"
  # Reference existing Virtual Network via data source
  virtual_network_name                = data.azurerm_virtual_network.existing.name
  virtual_network_resource_group_name = data.azurerm_virtual_network.existing.resource_group_name
  # Enable telemetry (AVM requirement)
  enable_telemetry = var.enable_telemetry
  # Location (inherited from VNet)
  location = data.azurerm_virtual_network.existing.location
  # Tags
  tags = {
    Environment = "Example"
    Purpose     = "Existing-Infrastructure-Demo"
  }
}
