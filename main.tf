locals {
  owners           = var.owners
  project          = var.business_divsion
  environment      = var.environment
  location         = lower(var.location)
  region_shortcode = (local.location == "uaenorth" ? "uan" : "unknown")
  common_tags = {
    owners      = local.owners
    project     = local.project
    environment = local.environment
  }
  account_tier             = (var.account_kind == "FileStorage" ? "Premium" : split("_", var.skuname)[0])
  account_replication_type = (local.account_tier == "Premium" ? "LRS" : split("_", var.skuname)[1])
}

module "res-id" {
  source = "./utility/random-identifier"
}

resource "azurerm_storage_account" "storeacc" {
  name                      = substr(format("%s%s", lower(replace(var.storage_account_name, "/[[:^alnum:]]/", "")), module.res-id.result), 0, 24)
  resource_group_name       = var.resource_group
  location                  = local.location
  account_kind              = var.account_kind
  account_tier              = local.account_tier
  account_replication_type  = local.account_replication_type
  enable_https_traffic_only = true
  min_tls_version           = var.min_tls_version
  tags                      = local.common_tags
  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
    versioning_enabled       = var.enable_versioning
    last_access_time_enabled = var.last_access_time_enabled
    change_feed_enabled      = var.change_feed_enabled
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? ["true"] : []
    content {
      default_action             = "Deny"
      bypass                     = var.network_rules.bypass
      ip_rules                   = var.network_rules.ip_rules
      virtual_network_subnet_ids = var.network_rules.subnet_ids
    }
  }
}

#--------------------------------------
# Storage Advanced Threat Protection 
#--------------------------------------
resource "azurerm_advanced_threat_protection" "atp" {
  target_resource_id = azurerm_storage_account.storeacc.id
  enabled            = var.enable_advanced_threat_protection
}

#-------------------------------
# Storage Container Creation
#-------------------------------
resource "azurerm_storage_container" "container" {
  count                 = length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = azurerm_storage_account.storeacc.name
  container_access_type = var.containers_list[count.index].access_type
}

#-------------------------------
# Storage Fileshare Creation
#-------------------------------
resource "azurerm_storage_share" "fileshare" {
  count                = length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.storeacc.name
  quota                = var.file_shares[count.index].quota
}

#-------------------------------
# Storage Tables Creation
#-------------------------------
resource "azurerm_storage_table" "tables" {
  count                = length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = azurerm_storage_account.storeacc.name
}

#-------------------------------
# Storage Queue Creation
#-------------------------------
resource "azurerm_storage_queue" "queues" {
  count                = length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = azurerm_storage_account.storeacc.name
}

#-------------------------------
# Storage Lifecycle Management
#-------------------------------
resource "azurerm_storage_management_policy" "lcpolicy" {
  count              = length(var.lifecycles) == 0 ? 0 : 1
  storage_account_id = azurerm_storage_account.storeacc.id

  dynamic "rule" {
    for_each = var.lifecycles
    iterator = rule
    content {
      name    = "rule${rule.key}"
      enabled = true
      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = ["blockBlob"]
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days
        }
        snapshot {
          delete_after_days_since_creation_greater_than = rule.value.snapshot_delete_after_days
        }
      }
    }
  }
}
