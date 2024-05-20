output "storage_account_name" {
  value = local.sa_name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "container_name" {
  value = module.storage-account.containers
}