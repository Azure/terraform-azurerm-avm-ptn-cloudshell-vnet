# =========================================
# Existing Infrastructure Outputs
# =========================================

# =========================================
# CloudShell VNet Module Outputs
# =========================================

output "container_subnet_id" {
  description = "The resource ID of the CloudShell container subnet."
  value       = module.cloudshell_vnet.container_subnet_id
}

output "existing_resource_group_name" {
  description = "The name of the existing resource group."
  value       = data.azurerm_resource_group.existing.name
}

output "existing_virtual_network_address_space" {
  description = "The address space of the existing virtual network."
  value       = data.azurerm_virtual_network.existing.address_space
}

output "existing_virtual_network_id" {
  description = "The resource ID of the existing virtual network."
  value       = data.azurerm_virtual_network.existing.id
}

output "location" {
  description = "The Azure region where resources were deployed."
  value       = module.cloudshell_vnet.location
}

output "network_profile_id" {
  description = "The resource ID of the Network Profile for CloudShell."
  value       = module.cloudshell_vnet.network_profile_id
}

output "network_profile_name" {
  description = "The name of the Network Profile."
  value       = module.cloudshell_vnet.network_profile_name
}

output "private_endpoint_id" {
  description = "The resource ID of the Private Endpoint for the Relay Namespace."
  value       = module.cloudshell_vnet.private_endpoint_id
}

output "relay_namespace_id" {
  description = "The resource ID of the Azure Relay Namespace."
  value       = module.cloudshell_vnet.relay_namespace_id
}

output "relay_namespace_name" {
  description = "The name of the Azure Relay Namespace."
  value       = module.cloudshell_vnet.relay_namespace_name
}

output "relay_subnet_id" {
  description = "The resource ID of the relay subnet."
  value       = module.cloudshell_vnet.relay_subnet_id
}

output "storage_account_id" {
  description = "The resource ID of the Storage Account."
  value       = module.cloudshell_vnet.storage_account_id
}

output "storage_account_name" {
  description = "The name of the Storage Account for CloudShell."
  value       = module.cloudshell_vnet.storage_account_name
}

output "storage_subnet_id" {
  description = "The resource ID of the storage subnet."
  value       = module.cloudshell_vnet.storage_subnet_id
}
