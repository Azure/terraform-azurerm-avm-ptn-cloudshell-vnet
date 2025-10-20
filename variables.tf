variable "container_subnet_address_prefix" {
  type        = string
  description = "Address prefix for the container subnet (minimum /28 recommended)."
  nullable    = false
}

# Required: Location
variable "location" {
  type        = string
  description = "Azure region where the CloudShell resources should be deployed. If not specified, uses the location of the existing VNet."
  nullable    = false
}

# Required: Relay Namespace Configuration
variable "relay_namespace_name" {
  type        = string
  description = "Name of the Azure Relay Namespace for CloudShell communication."
  nullable    = false
}

variable "relay_subnet_address_prefix" {
  type        = string
  description = "Address prefix for the relay subnet (minimum /28 recommended)."
  nullable    = false
}

# Required: Storage Account Configuration
variable "storage_account_name" {
  type        = string
  description = "Name of the Storage Account for CloudShell. Must be globally unique, 3-24 characters, lowercase letters and numbers only."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "The storage account name must be between 3 and 24 characters long and can only contain lowercase letters and numbers."
  }
}

variable "storage_subnet_address_prefix" {
  type        = string
  description = "Address prefix for the storage subnet (minimum /28 recommended)."
  nullable    = false
}

# Required: Existing Virtual Network Configuration
variable "virtual_network_name" {
  type        = string
  description = "Name of the existing virtual network where CloudShell subnets will be created."
  nullable    = false
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "Name of the resource group containing the existing virtual network."
  nullable    = false
}

# Subnet Configuration
variable "container_subnet_name" {
  type        = string
  default     = "cloudshell-containers"
  description = "Name of the subnet for CloudShell container instances."
  nullable    = false
}

# AVM required interface: enable_telemetry
variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "file_share_name" {
  type        = string
  default     = "cloudshell"
  description = "Name of the File Share within the Storage Account for CloudShell user data."
  nullable    = false
}

variable "file_share_quota_gb" {
  type        = number
  default     = 6
  description = "The maximum size of the file share in gigabytes. Minimum is 6 GB for CloudShell."
  nullable    = false

  validation {
    condition     = var.file_share_quota_gb >= 6
    error_message = "File share quota must be at least 6 GB for CloudShell."
  }
}

# Optional: Existing Private DNS Zone
variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Resource ID of an existing Private DNS Zone for privatelink.servicebus.windows.net. If not provided, DNS zone group will not be configured."
}

# Optional: Private Endpoint Configuration
variable "private_endpoint_name" {
  type        = string
  default     = "cloudshell-relay-pe"
  description = "Name of the Private Endpoint for Azure Relay."
  nullable    = false
}

variable "relay_subnet_name" {
  type        = string
  default     = "cloudshell-relay"
  description = "Name of the subnet for Azure Relay private endpoint."
  nullable    = false
}

# Optional: Storage Account Network Rules Bypass
variable "storage_account_network_bypass" {
  type        = set(string)
  default     = []
  description = "Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None."
  nullable    = false

  validation {
    condition = alltrue([
      for v in var.storage_account_network_bypass :
      contains(["Logging", "Metrics", "AzureServices", "None"], v)
    ])
    error_message = "storage_account_network_bypass must contain only: Logging, Metrics, AzureServices, or None."
  }
}

variable "storage_account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "The replication type of the storage account. Valid options are GRS, RAGRS, ZRS, GZRS, RAGZRS. LRS is not recommended for production."
  nullable    = false

  validation {
    condition     = contains(["GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "storage_account_replication_type must be one of: GRS, RAGRS, ZRS, GZRS, RAGZRS (LRS not allowed per Azure Well-Architected Framework)."
  }
}

# Optional: Storage Account Settings
variable "storage_account_tier" {
  type        = string
  default     = "Standard"
  description = "The tier of the storage account. Valid options are Standard or Premium."
  nullable    = false

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "storage_account_replication_type must be either Standard or Premium."
  }
}

variable "storage_subnet_name" {
  type        = string
  default     = "cloudshell-storage"
  description = "Name of the subnet for storage service endpoints."
  nullable    = false
}

# Optional: Tags
variable "tags" {
  type        = map(string)
  default     = null
  description = "Map of tags to assign to the CloudShell resources."
}
