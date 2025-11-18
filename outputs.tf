# =========================================
# CloudShell VNet Module Outputs
# =========================================

output "container_nsg_id" {
  description = "The resource ID of the Network Security Group for the container subnet."
  value       = module.nsg_container.resource_id
}

output "container_subnet_id" {
  description = "The resource ID of the container subnet for CloudShell instances."
  value       = azurerm_subnet.container.id
}

output "file_share_id" {
  description = "The resource ID of the file share."
  value       = "${module.storage_account.resource_id}/fileServices/default/shares/${var.file_share_name}"
}

output "file_share_name" {
  description = "The name of the file share for CloudShell user data."
  value       = var.file_share_name
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
  value       = module.private_endpoint.resource_id
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the Private Endpoint."
  value       = try(module.private_endpoint.private_endpoints[var.private_endpoint_name].private_ip_address, null)
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
  value       = module.nsg_relay.resource_id
}

output "relay_subnet_id" {
  description = "The resource ID of the relay subnet for private endpoints."
  value       = azurerm_subnet.relay.id
}

output "resource_group_name" {
  description = "The name of the resource group containing the CloudShell resources."
  value       = local.resource_group_name
}

# Required output per RMFR7
output "resource_id" {
  description = "The resource ID of the primary resource (Network Profile) for CloudShell VNet integration."
  value       = azurerm_network_profile.cloudshell.id
}

output "storage_account_id" {
  description = "The resource ID of the Storage Account for CloudShell."
  value       = module.storage_account.resource_id
}

output "storage_account_name" {
  description = "The name of the Storage Account for CloudShell."
  value       = module.storage_account.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the Storage Account."
  value       = module.storage_account.resource.primary_blob_endpoint
}

output "storage_nsg_id" {
  description = "The resource ID of the Network Security Group for the storage subnet."
  value       = module.nsg_storage.resource_id
}

output "storage_subnet_id" {
  description = "The resource ID of the storage subnet."
  value       = azurerm_subnet.storage.id
}

output "virtual_network_id" {
  description = "The resource ID of the Virtual Network."
  value       = data.azurerm_virtual_network.vnet.id
}
