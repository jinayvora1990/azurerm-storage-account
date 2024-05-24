locals {
  rg_name        = "${var.subscription_name}-rg"
  sa_name        = "${var.subscription_name}sa"
  container_name_prefix = "${local.sa_name}-tfstate"
  non_prod_container_names = ["${local.container_name_prefix}-dev", "${local.container_name_prefix}-sat", "${local.container_name_prefix}-uat"]
  prod_container_names = ["${local.container_name_prefix}-staging", "${local.container_name_prefix}-prod"]
}

resource "azurerm_resource_group" "rg" {
  location = "uaenorth"
  name     = local.rg_name
}

module "storage-account" {
  source               = "git@github.com:jinayvora1990/azurerm-storage-account.git"
  resource_group       = local.rg_name
  storage_account_name = local.sa_name
  containers_list      = var.env == "prod" ? local.prod_container_names : local.non_prod_container_names
}
