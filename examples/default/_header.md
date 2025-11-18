# Default Example

This example demonstrates how to deploy Azure CloudShell with Virtual Network integration using this AVM pattern module.

## Overview

This example will create:

- A new Resource Group
- A new Virtual Network (10.0.0.0/16)
- CloudShell infrastructure including:
  - 3 subnets (container, relay, storage) using /28 address spaces
  - Network Security Groups for each subnet
  - Storage Account with TLS 1.2 and HTTPS enforcement
  - File Share for CloudShell user data
  - Azure Relay Namespace
  - Private Endpoint for secure relay communication
  - Network Profile for container instances

## Prerequisites

Before deploying this example, ensure you have:

1. Azure CLI installed and authenticated
2. Terraform >= 1.9 installed
3. Appropriate Azure subscription permissions to create resources

## Usage

1. Clone this repository and navigate to this example directory
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the planned changes:
   ```bash
   terraform plan
   ```
4. Deploy the resources:
   ```bash
   terraform apply
   ```

## Customization

You can customize the deployment by modifying the `main.tf` file:

- **Subnet addressing**: Adjust the subnet address prefixes to fit your network design
- **Storage configuration**: Modify storage account tier, replication type, or file share quota
- **Private DNS Zone**: Uncomment and provide an existing Private DNS Zone ID if you have one
- **Tags**: Add or modify tags to match your organization's standards

## Testing CloudShell

After deployment:

1. Navigate to the Azure Portal
2. Open CloudShell (icon in the top navigation bar)
3. When prompted, select "Advanced settings"
4. Choose the Storage Account and File Share created by this module
5. Select the region where resources were deployed
6. CloudShell will now use the private VNet configuration

## Cleanup

To remove all resources created by this example:

```bash
terraform destroy
```

**Note**: Before destroying, ensure no active CloudShell sessions are using the Network Profile. You may need to wait 30 minutes to several hours after disconnecting from CloudShell for the container instance to be automatically deleted by Azure.
