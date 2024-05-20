locals {
  rg_name = "${var.team_name}-rg"
  sa_name = "${var.team_name}sa"
  container_name = "${local.sa_name}-tfstate-container"
}

resource "azurerm_resource_group" "rg" {
  location = "uaenorth"
  name     = local.rg_name
}

module "storage-account" {
  source = "git@github.com:jinayvora1990/azurerm-storage-account.git"
  resource_group = local.rg_name
  storage_account_name = local.rg_name
  containers_list = [local.container_name]
}