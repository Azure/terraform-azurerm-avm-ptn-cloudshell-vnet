# terraform-azurerm-avm-ptn-cloudshell-vnet

This Azure Verified Module (AVM) pattern deploys Azure CloudShell with Virtual Network integration, providing a secure and compliant way to use CloudShell within your private network infrastructure.

## Features

This module creates and configures the following resources for CloudShell VNet integration:

- **3 Dedicated Subnets** with appropriate configurations:
  - Container subnet with delegation to `Microsoft.ContainerInstance/containerGroups`
  - Relay subnet for private endpoint connectivity
  - Storage subnet with storage service endpoints
- **Network Security Groups** for each subnet
- **Storage Account** with security compliance:
  - Minimum TLS version 1.2
  - HTTPS traffic only
  - Network rules to restrict access to CloudShell subnets
  - File share for persistent CloudShell user data
- **Azure Relay Namespace** for secure communication
- **Private Endpoint** for the Relay Namespace
- **Network Profile** for container instances
- **Optional Private DNS Zone** integration for private endpoint name resolution

## Benefits

- ✅ **Security Compliance**: Enforces TLS 1.2 and HTTPS-only traffic
- ✅ **Network Isolation**: CloudShell operates within your private virtual network
- ✅ **Azure Policy Compatible**: Supports enterprise governance requirements
- ✅ **Flexible Configuration**: Works with existing VNets and Private DNS Zones
- ✅ **AVM Compliant**: Follows Azure Verified Modules specifications

## Prerequisites

Before using this module, you must have:

1. An existing **Virtual Network** in Azure
2. Sufficient address space for three /28 subnets (minimum recommended)
3. Appropriate Azure RBAC permissions to create resources
4. (Optional) An existing Private DNS Zone for `privatelink.servicebus.windows.net`

## Usage

### Basic Usage

```hcl
module "cloudshell_vnet" {
  source  = "Azure/avm-ptn-cloudshell-vnet/azurerm"
  version = "~> 1.0"

  # Existing Virtual Network
  virtual_network_name                = "my-vnet"
  virtual_network_resource_group_name = "my-rg"

  # Storage Account Configuration
  storage_account_name = "cloudshellst123"  # Must be globally unique
  
  # Relay Namespace
  relay_namespace_name = "cloudshell-relay"

  # Subnet Configuration
  container_subnet_address_prefix = "10.0.1.0/28"
  relay_subnet_address_prefix     = "10.0.1.16/28"
  storage_subnet_address_prefix   = "10.0.1.32/28"
}
```

### Usage with Existing Private DNS Zone

```hcl
module "cloudshell_vnet" {
  source  = "Azure/avm-ptn-cloudshell-vnet/azurerm"
  version = "~> 1.0"

  # Existing Virtual Network
  virtual_network_name                = "my-vnet"
  virtual_network_resource_group_name = "my-rg"

  # Storage Account Configuration
  storage_account_name = "cloudshellst123"
  
  # Relay Namespace
  relay_namespace_name = "cloudshell-relay"

  # Subnet Configuration
  container_subnet_address_prefix = "10.0.1.0/28"
  relay_subnet_address_prefix     = "10.0.1.16/28"
  storage_subnet_address_prefix   = "10.0.1.32/28"

  # Existing Private DNS Zone
  private_dns_zone_id = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
}
```

## Important Notes

### Subnet Sizing

Microsoft recommends **minimum /28 subnets** for each of the three required subnets. Larger subnets may be needed depending on expected CloudShell usage.

### Deletion Considerations

When destroying resources, the Network Profile may fail to delete if CloudShell container instances are still active. After disconnecting from CloudShell, Azure automatically deletes the container instance, but this can take **30 minutes to several hours**. Monitor the Network Profile's activity logs for the "Removes Containers" operation before attempting to delete.

### Private DNS Zone

If you provide an existing Private DNS Zone ID, ensure:
- The zone is for `privatelink.servicebus.windows.net`
- It is linked to the Virtual Network
- You have permissions to create DNS records

If no Private DNS Zone is provided, name resolution for the private endpoint will need to be managed separately (e.g., via Azure Policy or manual DNS configuration).

## Examples

See the [examples](./examples/) directory for complete usage examples:

- [**default**](./examples/default/) - Basic CloudShell VNet deployment with a new VNet

## Contributing

This module follows the Azure Verified Modules (AVM) specifications. Contributions are welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for details.

## References

- [Azure CloudShell in a Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/cloud-shell/vnet/overview)
- [Azure Verified Modules](https://aka.ms/avm)
- [Module Issue #1811](https://github.com/Azure/Azure-Verified-Modules/issues/1811)
