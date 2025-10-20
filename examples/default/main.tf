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

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# Create a resource group for the example VNet
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# Create an example Virtual Network
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

# Generate a random string for unique storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  lower   = true
  numeric = true
  special = false
  upper   = false
}

# Deploy CloudShell with VNet Integration
module "cloudshell_vnet" {
  source = "../../"

  container_subnet_address_prefix = "10.0.1.0/28"
  # Relay Namespace
  relay_namespace_name        = "cloudshell-relay-${random_string.storage_suffix.result}"
  relay_subnet_address_prefix = "10.0.1.16/28"
  # Storage Account Configuration
  storage_account_name          = "cloudshell${random_string.storage_suffix.result}"
  storage_subnet_address_prefix = "10.0.1.32/28"
  # Existing Virtual Network
  virtual_network_name                = azurerm_virtual_network.this.name
  virtual_network_resource_group_name = azurerm_virtual_network.this.resource_group_name
  # Subnet Configuration (using /28 subnets as recommended)
  container_subnet_name = "cloudshell-containers"
  # Enable telemetry (AVM requirement)
  enable_telemetry    = var.enable_telemetry
  file_share_name     = "cloudshell"
  file_share_quota_gb = 6
  # Location (will use VNet location if not specified)
  location = azurerm_resource_group.this.location
  # Private Endpoint
  private_endpoint_name = "cloudshell-relay-pe"
  relay_subnet_name     = "cloudshell-relay"
  storage_subnet_name   = "cloudshell-storage"
  # Tags
  tags = {
    Environment = "Example"
    Purpose     = "CloudShell-VNet-Demo"
  }
}
