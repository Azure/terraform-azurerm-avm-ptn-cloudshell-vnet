# =========================================
# CloudShell VNet Example Outputs
# =========================================

output "container_subnet_id" {
  description = "The resource ID of the CloudShell container subnet."
  value       = module.cloudshell_vnet.container_subnet_id
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

output "resource_group_name" {
  description = "The name of the resource group containing the resources."
  value       = azurerm_resource_group.this.name
}

output "storage_account_id" {
  description = "The resource ID of the Storage Account."
  value       = module.cloudshell_vnet.storage_account_id
}

output "storage_account_name" {
  description = "The name of the Storage Account for CloudShell."
  value       = module.cloudshell_vnet.storage_account_name
}

output "virtual_network_id" {
  description = "The resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.this.name
}
