# Existing Infrastructure Example

This example demonstrates how to deploy Azure CloudShell with Virtual Network integration using the **data source pattern** to reference existing infrastructure.

## Overview

This example shows the pattern for integrating CloudShell into environments where infrastructure already exists. It demonstrates:

- ✅ Using **data sources** to reference existing Resource Groups and Virtual Networks
- ✅ Deploying CloudShell infrastructure into an existing VNet
- ✅ Creating subnets within existing network address space
- ✅ The recommended approach for brownfield Azure environments

> **Note**: For demonstration purposes, this example creates a "simulated existing" VNet, then references it via data sources. In a real scenario, you would only use the data source blocks to reference truly pre-existing infrastructure.

## What This Example Demonstrates

This example pattern shows how to:

1. **Reference existing infrastructure** using `data` blocks (Resource Group, VNet)
2. **Deploy CloudShell resources** into the existing VNet
3. **Create new subnets** within available address space
4. **Use randomized names** for globally unique resources (storage account, relay namespace)

## Real-World Usage

In a production environment, you would:

1. **Remove the resource creation blocks** (the `resource "azurerm_resource_group"` and `resource "azurerm_virtual_network"` blocks)
2. **Keep only the data source blocks** pointing to your actual existing resources
3. **Update the data source names** to match your existing resource names
4. **Verify subnet address availability** in your VNet before deploying

## Example: Adapting for Your Environment

```hcl
# Reference YOUR existing Resource Group
data "azurerm_resource_group" "existing" {
  name = "my-production-rg"  # Your actual RG name
}

# Reference YOUR existing Virtual Network
data "azurerm_virtual_network" "existing" {
  name                = "my-production-vnet"  # Your actual VNet name
  resource_group_name = "my-production-rg"
}

# Then use the module as shown in the example
module "cloudshell_vnet" {
  source = "Azure/avm-ptn-cloudshell-vnet/azurerm"
  
  virtual_network_name                = data.azurerm_virtual_network.existing.name
  virtual_network_resource_group_name = data.azurerm_virtual_network.existing.resource_group_name
  # ... rest of configuration
}
```

## Deployment

This example is fully self-contained and deployable as-is:

```bash
terraform init
terraform plan
terraform apply
```

## Key Differences from Default Example

| Aspect | Default Example | Existing Infrastructure Example |
|--------|----------------|--------------------------------|
| **VNet Creation** | Creates new VNet | References existing VNet via data source |
| **Use Case** | Greenfield deployment | Brownfield/existing environment |
| **Pattern** | Direct resource creation | Data source → Module pattern |
| **Flexibility** | Quick start | Production-ready pattern |

## When to Use This Pattern

Use this **existing-infrastructure pattern** when:
- ✅ You have an established Azure Landing Zone
- ✅ VNets and Resource Groups are already deployed
- ✅ You need to follow organizational standards for infrastructure references
- ✅ You want to avoid creating duplicate base infrastructure

Use the **default example** when:
- ✅ Starting a new project from scratch
- ✅ Testing or proof-of-concept scenarios
- ✅ You want a quick, self-contained deployment
