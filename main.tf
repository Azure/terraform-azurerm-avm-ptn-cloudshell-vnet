# =========================================
# Network Security Groups (using AVM module)
# =========================================

# NSG for Container Subnet
module "nsg_container" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.3"

  enable_telemetry    = var.enable_telemetry
  location            = local.location
  name                = "nsg-${var.container_subnet_name}"
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

# NSG for Relay Subnet
module "nsg_relay" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.3"

  enable_telemetry    = var.enable_telemetry
  location            = local.location
  name                = "nsg-${var.relay_subnet_name}"
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

# NSG for Storage Subnet
module "nsg_storage" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.3"

  enable_telemetry    = var.enable_telemetry
  location            = local.location
  name                = "nsg-${var.storage_subnet_name}"
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

# =========================================
# Subnets (using azurerm provider)
# =========================================

# Container Subnet with Container Instance Delegation
resource "azurerm_subnet" "container" {
  name                 = var.container_subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.container_subnet_address_prefix]

  delegation {
    name = "CloudShellDelegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
    }
  }

  service_endpoints = ["Microsoft.Storage"]
}

# Associate NSG with Container Subnet
resource "azurerm_subnet_network_security_group_association" "container" {
  subnet_id                 = azurerm_subnet.container.id
  network_security_group_id = module.nsg_container.resource_id
}

# Relay Subnet for Private Endpoint
resource "azurerm_subnet" "relay" {
  name                 = var.relay_subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.relay_subnet_address_prefix]

  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
}

# Associate NSG with Relay Subnet
resource "azurerm_subnet_network_security_group_association" "relay" {
  subnet_id                 = azurerm_subnet.relay.id
  network_security_group_id = module.nsg_relay.resource_id
}

# Storage Subnet with Storage Service Endpoint
resource "azurerm_subnet" "storage" {
  name                 = var.storage_subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.storage_subnet_address_prefix]

  service_endpoints = ["Microsoft.Storage"]
}

# Associate NSG with Storage Subnet
resource "azurerm_subnet_network_security_group_association" "storage" {
  subnet_id                 = azurerm_subnet.storage.id
  network_security_group_id = module.nsg_storage.resource_id
}

# =========================================
# Storage Account for CloudShell (using AVM module)
# =========================================

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  enable_telemetry         = var.enable_telemetry
  location                 = local.location
  name                     = lower(var.storage_account_name)
  resource_group_name      = local.resource_group_name
  account_replication_type = var.storage_account_replication_type
  account_tier             = var.storage_account_tier
  access_tier              = "Cool"
  account_kind             = "StorageV2"

  # Security compliance requirements
  shared_access_key_enabled  = true
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  tags = local.tags

  # Network rules - deny by default, allow from CloudShell subnets
  network_rules = {
    bypass         = var.storage_account_network_bypass
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.container.id,
      azurerm_subnet.storage.id
    ]
  }

  # File share for CloudShell
  shares = {
    cloudshell = {
      name        = var.file_share_name
      quota       = var.file_share_quota_gb
      access_tier = "Cool"
    }
  }
}


# =========================================
# Azure Relay Namespace
# =========================================

resource "azurerm_relay_namespace" "cloudshell" {
  location            = local.location
  name                = var.relay_namespace_name
  resource_group_name = local.resource_group_name
  sku_name            = "Standard"
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# =========================================
# Private Endpoint for Relay Namespace (using AVM module)
# =========================================

module "private_endpoint" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "~> 0.1"

  enable_telemetry               = var.enable_telemetry
  location                       = local.location
  name                           = var.private_endpoint_name
  resource_group_name            = local.resource_group_name
  subnet_resource_id             = azurerm_subnet.relay.id
  private_connection_resource_id = azurerm_relay_namespace.cloudshell.id
  subresource_names              = ["namespace"]
  network_interface_name         = "${var.private_endpoint_name}-nic"
  tags                           = local.tags

  # Optional: Private DNS Zone Group (if DNS zone ID is provided)
  private_dns_zone_resource_ids = var.private_dns_zone_id != null ? [var.private_dns_zone_id] : []

  depends_on = [
    azurerm_subnet.relay,
    azurerm_relay_namespace.cloudshell
  ]
}

# =========================================
# Network Profile for Container Instances
# =========================================

resource "azurerm_network_profile" "cloudshell" {
  location            = local.location
  name                = local.network_profile_name
  resource_group_name = local.resource_group_name
  tags                = local.tags

  container_network_interface {
    name = "eth-${var.container_subnet_name}"

    ip_configuration {
      name      = "ipconfig-${var.container_subnet_name}"
      subnet_id = azurerm_subnet.container.id
    }
  }

  depends_on = [azurerm_subnet.container]

  lifecycle {
    ignore_changes = [tags]
  }
}
