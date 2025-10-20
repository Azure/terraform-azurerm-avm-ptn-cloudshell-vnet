# Data source for existing Virtual Network
data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}

# Computed local values
locals {
  # Use provided location or default to VNet location
  location = coalesce(var.location, data.azurerm_virtual_network.vnet.location)
  # Network Profile naming convention
  network_profile_name = "aci-networkProfile-${local.location}"
  # Resource group is derived from the existing VNet
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  # Tags with lifecycle ignore to prevent Terraform from managing tags added by Azure
  tags = var.tags
}
