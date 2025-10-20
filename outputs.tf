# =========================================
# CloudShell VNet Module Outputs
# =========================================

# Required output per RMFR7
output "resource_id" {
  description = "The resource ID of the primary resource (Network Profile) for CloudShell VNet integration."
  value       = azurerm_network_profile.cloudshell.id
}

output "container_nsg_id" {
  description = "The resource ID of the Network Security Group for the container subnet."
  value       = azurerm_network_security_group.container.id
}

output "container_subnet_id" {
  description = "The resource ID of the container subnet for CloudShell instances."
  value       = azapi_resource.container_subnet.id
}

output "file_share_id" {
  description = "The resource ID of the file share."
  value       = azurerm_storage_share.cloudshell.id
}

output "file_share_name" {
  description = "The name of the file share for CloudShell user data."
  value       = azurerm_storage_share.cloudshell.name
}

output "location" {
  description = "The Azure region where the resources were deployed."
  value       = local.location
}

output "network_profile_id" {
  description = "The resource ID of the Network Profile for CloudShell container instances."
  value       = azurerm_network_profile.cloudshell.id
}

output "network_profile_name" {
  description = "The name of the Network Profile."
  value       = azurerm_network_profile.cloudshell.name
}

output "private_endpoint_id" {
  description = "The resource ID of the Private Endpoint for the Relay Namespace."
  value       = azurerm_private_endpoint.relay.id
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the Private Endpoint."
  value       = try(azurerm_private_endpoint.relay.private_service_connection[0].private_ip_address, null)
}

output "relay_namespace_id" {
  description = "The resource ID of the Azure Relay Namespace."
  value       = azurerm_relay_namespace.cloudshell.id
}

output "relay_namespace_name" {
  description = "The name of the Azure Relay Namespace."
  value       = azurerm_relay_namespace.cloudshell.name
}

output "relay_nsg_id" {
  description = "The resource ID of the Network Security Group for the relay subnet."
  value       = azurerm_network_security_group.relay.id
}

output "relay_subnet_id" {
  description = "The resource ID of the relay subnet for private endpoints."
  value       = azapi_resource.relay_subnet.id
}

output "resource_group_name" {
  description = "The name of the resource group containing the CloudShell resources."
  value       = local.resource_group_name
}

output "storage_account_id" {
  description = "The resource ID of the Storage Account for CloudShell."
  value       = azurerm_storage_account.cloudshell.id
}

output "storage_account_name" {
  description = "The name of the Storage Account for CloudShell."
  value       = azurerm_storage_account.cloudshell.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the Storage Account."
  value       = azurerm_storage_account.cloudshell.primary_blob_endpoint
}

output "storage_nsg_id" {
  description = "The resource ID of the Network Security Group for the storage subnet."
  value       = azurerm_network_security_group.storage.id
}

output "storage_subnet_id" {
  description = "The resource ID of the storage subnet."
  value       = azapi_resource.storage_subnet.id
}

output "virtual_network_id" {
  description = "The resource ID of the Virtual Network."
  value       = data.azurerm_virtual_network.vnet.id
}
