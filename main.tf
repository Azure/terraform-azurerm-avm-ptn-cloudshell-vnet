# =========================================
# Network Security Groups
# =========================================

# NSG for Container Subnet
resource "azurerm_network_security_group" "container" {
  location            = local.location
  name                = "nsg-${var.container_subnet_name}"
  resource_group_name = local.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# NSG for Relay Subnet
resource "azurerm_network_security_group" "relay" {
  location            = local.location
  name                = "nsg-${var.relay_subnet_name}"
  resource_group_name = local.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# NSG for Storage Subnet
resource "azurerm_network_security_group" "storage" {
  location            = local.location
  name                = "nsg-${var.storage_subnet_name}"
  resource_group_name = local.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# =========================================
# Subnets (using azapi for advanced features)
# =========================================

# Container Subnet with Container Instance Delegation
resource "azapi_resource" "container_subnet" {
  name      = var.container_subnet_name
  parent_id = data.azurerm_virtual_network.vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  body = {
    properties = {
      addressPrefix = var.container_subnet_address_prefix
      delegations = [
        {
          name = "CloudShellDelegation"
          properties = {
            serviceName = "Microsoft.ContainerInstance/containerGroups"
          }
        }
      ]
      networkSecurityGroup = {
        id = azurerm_network_security_group.container.id
      }
      serviceEndpoints = [
        {
          locations = [
            local.location
          ]
          service = "Microsoft.Storage"
        }
      ]
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["*"]
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Relay Subnet for Private Endpoint
resource "azapi_resource" "relay_subnet" {
  name      = var.relay_subnet_name
  parent_id = data.azurerm_virtual_network.vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  body = {
    properties = {
      addressPrefix = var.relay_subnet_address_prefix
      networkSecurityGroup = {
        id = azurerm_network_security_group.relay.id
      }
      privateEndpointNetworkPolicies    = "Disabled"
      privateLinkServiceNetworkPolicies = "Enabled"
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["*"]
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Storage Subnet with Storage Service Endpoint
resource "azapi_resource" "storage_subnet" {
  name      = var.storage_subnet_name
  parent_id = data.azurerm_virtual_network.vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  body = {
    properties = {
      addressPrefix = var.storage_subnet_address_prefix
      networkSecurityGroup = {
        id = azurerm_network_security_group.storage.id
      }
      serviceEndpoints = [
        {
          locations = [
            local.location
          ]
          service = "Microsoft.Storage"
        }
      ]
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["*"]
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# =========================================
# Storage Account for CloudShell
# =========================================

resource "azurerm_storage_account" "cloudshell" {
  account_replication_type = var.storage_account_replication_type
  account_tier             = var.storage_account_tier
  location                 = local.location
  name                     = lower(var.storage_account_name)
  resource_group_name      = local.resource_group_name
  access_tier              = "Cool"
  account_kind             = "StorageV2"
  # Security compliance requirements
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  tags                       = local.tags

  # Network rules - deny by default, allow from CloudShell subnets
  network_rules {
    default_action = "Deny"
    bypass         = var.storage_account_network_bypass
    virtual_network_subnet_ids = [
      azapi_resource.container_subnet.id,
      azapi_resource.storage_subnet.id
    ]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# File Share for CloudShell user data
resource "azurerm_storage_share" "cloudshell" {
  name               = var.file_share_name
  quota              = var.file_share_quota_gb
  storage_account_id = azurerm_storage_account.cloudshell.id
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
# Private Endpoint for Relay Namespace
# =========================================

resource "azurerm_private_endpoint" "relay" {
  location            = local.location
  name                = var.private_endpoint_name
  resource_group_name = local.resource_group_name
  subnet_id           = azapi_resource.relay_subnet.id
  tags                = local.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = var.private_endpoint_name
    private_connection_resource_id = azurerm_relay_namespace.cloudshell.id
    subresource_names              = ["namespace"]
  }
  # Optional: Private DNS Zone Group (if DNS zone ID is provided)
  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  depends_on = [
    azapi_resource.relay_subnet,
    azurerm_relay_namespace.cloudshell
  ]

  lifecycle {
    ignore_changes = [
      private_dns_zone_group, # May be managed by Azure Policy
      tags
    ]
  }
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
      subnet_id = azapi_resource.container_subnet.id
    }
  }

  depends_on = [azapi_resource.container_subnet]

  lifecycle {
    ignore_changes = [tags]
  }
}
